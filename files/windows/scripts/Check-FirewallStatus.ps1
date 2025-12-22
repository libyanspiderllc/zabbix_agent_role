# Check-FirewallStatus.ps1
# This script checks the status of Windows Firewall profiles and outputs JSON for Zabbix.

try {
    # Get all firewall profiles
    $profiles = Get-NetFirewallProfile -ErrorAction Stop

    # Initialize a hashtable to store statuses
    $status = [ordered]@{}

    # Loop through each profile type we care about
    foreach ($type in @("Domain", "Private", "Public")) {
        $profile = $profiles | Where-Object { $_.Name -eq $type }
        if ($profile) {
            # Convert boolean Enabled state to 1 (true) or 0 (false)
            $status[$type] = [int]($profile.Enabled)
        } else {
            # Handle missing profile if necessary, or just null
            $status[$type] = $null
        }
    }

    # Convert the hashtable to JSON and suppress the ReadOnly property or any other noise
    # Depth 2 is usually enough, Compress for single line output
    $status | ConvertTo-Json -Compress
} catch {
    # In case of error, output a JSON with error info, or just the error message
    # Zabbix might treat non-JSON as text, but let's try to be clean.
    $errorOutput = @{
        "error" = $_.Exception.Message
    }
    $errorOutput | ConvertTo-Json -Compress
    exit 1
}
