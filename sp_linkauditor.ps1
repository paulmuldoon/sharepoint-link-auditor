param(
    [Alias("u")]
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,

    [Alias("i")]
    [Parameter(Mandatory = $true)]
    [string]$ClientId,

    [Alias("o")]
    [string]$OutputFile = "broken-links.csv"
)

Connect-PnPOnline `
    -Url $SiteUrl `
    -ClientId $ClientId `
    -Interactive

$Pages = Get-PnPListItem -List "Site Pages"

$Results = @()

foreach ($Page in $Pages)
{
    Write-Host "Checking page: $($Page['FileLeafRef'])"

    $Content = $Page["CanvasContent1"]

    if ([string]::IsNullOrEmpty($Content)) {
        continue
    }

    $Urls = :Matches(
        $Content,
        'https?://[^\s"''<>]+'
    ) | ForEach-Object { $_.Value } |
      Select-Object -Unique

    foreach ($Url in $Urls)
    {
        try
        {
            $Response = Invoke-WebRequest `
                -Uri $Url `
                -Method Head `
                -MaximumRedirection 5 `
                -ErrorAction Stop

            $Status = $Response.StatusCode
        }
        catch
        {
            if ($_.Exception.Response)
            {
                $Status = [int]$_.Exception.Response.StatusCode
            }
            else
            {
                $Status = 0
            }
        }

        Write-Host "$Status - $Url"

        if ($Status -ge 400 -or $Status -eq 0)
        {
            $Results += [PSCustomObject]@{
                Page       = $Page["FileLeafRef"]
                PageUrl = "$SiteUrl/SitePages/$($Page['FileLeafRef'])"
                LinkUrl    = $Url
                StatusCode = $Status
                CheckedAt  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
    }
}

$Results | Export-Csv `
    -Path $OutputFile `
    -NoTypeInformation

Write-Host ""
Write-Host "Audit complete."
Write-Host "Broken links found: $($Results.Count)"
Write-Host "Report written to: $OutputFile"
``