[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)]
  [String]$ResourceGroupName,

  [Parameter(Mandatory=$true)]
  [String]$VMScaleSetName,

  [Parameter(Mandatory=$false)]
  [Int]$ExpireHours = 12,

  [Parameter(Mandatory=$false)]
  [Switch]$WhatIf
)

$ScriptName = $MyInvocation.MyCommand.Name
$StartTime = Get-Date

If ($WhatIf) {
  Write-Host "[$ScriptName] WhatIf switch enabled: No changes will be made"
}

Try {
  # Find the name of the image used by the VM Scale Set
  $AgentPool = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSetName
  $ImageName = ($AgentPool.VirtualMachineProfile.StorageProfile.ImageReference.Id).Split('/')[-1]
  Write-Host "[$ScriptName] VM Scale Set $VMScaleSetName is currently using image $ImageName"

  # Get all Images in the resource group
  $Images = Get-AzImage -ResourceGroupName $ResourceGroupName
  Write-Host "[$ScriptName] Found $($Images.Count) images in resource group $ResourceGroupName"

  If ($Images.Count -le 1) {
    Write-Host "[$ScriptName] Exiting: Nothing to do!"
    Exit 0
  }

} Catch {
  Write-Host "##vso[task.LogIssue type=error;]$($_.Exception.Message)"
  Exit 1
}

$RemovedCount = 0
Foreach ($Image in $Images) {
  # Extract the date part from the image name using a regular expression
  if ($Image.Name -match '\d{2}-\w+-\d{4}-\d{4}[ap]m') {
    $DateString = $matches[0]
    Write-Host "Debug: DateString = '$DateString'"  # Debug output

    Try {
      $ImageDate = [DateTime]::ParseExact($DateString, 'dd-MMMM-yyyy-hh:mm', $null)
      # $ImageDate = [DateTime]::ParseExact($DateString, 'yyyyMMddHHmmss', $null)
    } Catch {
      Write-Host "Error parsing date: $DateString"
      Continue
    }

    # Remove any images not in-use by the VM Scale Set and >=12 hours old
    If (!($Image.Name -eq $ImageName) -and ($ImageDate -le $StartTime.AddHours(-$ExpireHours))) {
      Try {
        If ($WhatIf) {
          Write-Host "[$ScriptName] [WhatIf] Would have removed image: $($Image.Name)"
          $RemovedCount++

        } Else {
          Write-Host "[$ScriptName] Removing image: $($Image.Name)`n"
          Remove-AzImage -ResourceGroupName $ResourceGroupName -ImageName $Image.Name -Force
          Write-Host "[$ScriptName] Successfully removed image: $($Image.Name)"
          $RemovedCount++
        }

      } Catch {
        Write-Host "[$ScriptName] Failed to remove image: $($Image.Name)"
        Write-Host "##vso[task.LogIssue type=warning;]$($_.Exception.Message)"
        Continue
      }

    } Else {
      Write-Host "[$ScriptName] Skipping image: $($Image.Name)"
    }
  } Else {
    Write-Host "[$ScriptName] No valid date found in image name: $($Image.Name)"
  }
}

If ($WhatIf) {
  Write-Host "[$ScriptName] [WhatIf] Would have removed $RemovedCount images"
} Else {
  $RunTime = New-TimeSpan -Start $StartTime -End (Get-Date)
  Write-Host "[$ScriptName] Removed $RemovedCount images"
  Write-Host "[$ScriptName] Script completed in $($RunTime.Minutes) minutes and $($RunTime.Seconds) seconds"
}

Exit 0
