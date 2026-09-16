# Run with powershell.exe -NoProfile -STA -File <path>, or add -Terminal in a user-operated console.
[CmdletBinding()]
param([switch]$Terminal)

Set-PSDebug -Off
$ErrorActionPreference = 'Stop'
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This helper requires native Windows for DPAPI storage.'
}
if ([string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
    throw 'LOCALAPPDATA is unavailable; run as the Windows user who will use SerpApi.'
}

function Assert-SerpApiStorePath {
    param([string]$Path)
    $current = [System.IO.Path]::GetFullPath($Path)
    while ($current) {
        $item = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
        if ($item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            throw 'The credential path must not contain symbolic links or junctions.'
        }
        $current = [System.IO.Path]::GetDirectoryName($current)
    }
}

function Read-SerpApiSecret {
    if ($Terminal) {
        return Read-Host 'SerpApi API key (from https://serpapi.com/dashboard)' -AsSecureString
    }
    if (-not [Environment]::UserInteractive) {
        throw 'No interactive desktop. Use a client secret field or run this helper yourself with -Terminal.'
    }
    if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
        throw 'Launch the password dialog with powershell.exe -NoProfile -STA -File <helper path>.'
    }
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $form = New-Object System.Windows.Forms.Form
    $inputBox = New-Object System.Windows.Forms.TextBox
    try {
        $form.Text = 'Set up SerpApi'
        $form.ClientSize = New-Object System.Drawing.Size(460, 190)
        $form.FormBorderStyle = 'FixedDialog'
        $form.StartPosition = 'CenterScreen'
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.TopMost = $true

        $label = New-Object System.Windows.Forms.Label
        $label.Text = "Paste your API key from serpapi.com/dashboard.`r`nSave encrypts it for this Windows user on this machine."
        $label.Location = New-Object System.Drawing.Point(16, 16)
        $label.Size = New-Object System.Drawing.Size(428, 44)
        $inputBox.Location = New-Object System.Drawing.Point(16, 68)
        $inputBox.Size = New-Object System.Drawing.Size(428, 24)
        $inputBox.UseSystemPasswordChar = $true
        $inputBox.AccessibleName = 'SerpApi API key'
        $inputBox.TabIndex = 0

        $save = New-Object System.Windows.Forms.Button
        $save.Text = 'Save'
        $save.Location = New-Object System.Drawing.Point(264, 132)
        $save.Size = New-Object System.Drawing.Size(84, 30)
        $save.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $save.TabIndex = 1
        $cancel = New-Object System.Windows.Forms.Button
        $cancel.Text = 'Cancel'
        $cancel.Location = New-Object System.Drawing.Point(360, 132)
        $cancel.Size = New-Object System.Drawing.Size(84, 30)
        $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $cancel.TabIndex = 2
        $form.Controls.AddRange(@($label, $inputBox, $save, $cancel))
        $form.AcceptButton = $save
        $form.CancelButton = $cancel
        $form.Add_Shown({ $inputBox.Focus() | Out-Null })

        if ($form.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            throw 'SerpApi setup cancelled; no key was saved.'
        }
        if ([string]::IsNullOrWhiteSpace($inputBox.Text) -or $inputBox.Text -match '[\r\n]') {
            throw 'Enter a nonempty, single-line API key.'
        }
        return ConvertTo-SecureString -String $inputBox.Text -AsPlainText -Force
    }
    finally {
        $inputBox.Clear()
        $inputBox.Dispose()
        $form.Dispose()
    }
}

$serpapiDir = Join-Path $env:LOCALAPPDATA 'SerpApi'
$serpapiKeyFile = Join-Path $serpapiDir 'api-key.dpapi'
Assert-SerpApiStorePath $serpapiKeyFile
if (Test-Path -LiteralPath $serpapiKeyFile) {
    throw 'A stored key already exists; reuse it or explicitly rotate it.'
}
$serpapiSecret = $null
$serpapiPlain = $null
$serpapiStream = $null
try {
    $serpapiSecret = Read-SerpApiSecret
    if ($null -eq $serpapiSecret -or $serpapiSecret.Length -eq 0) {
        throw 'No key was entered; nothing was saved.'
    }
    $serpapiPlain = [System.Net.NetworkCredential]::new('', $serpapiSecret).Password
    if ([string]::IsNullOrWhiteSpace($serpapiPlain) -or $serpapiPlain -match '[\r\n]') {
        throw 'Enter a nonempty, single-line API key.'
    }
    $serpapiPlain = $null
    $serpapiEncrypted = ConvertFrom-SecureString -SecureString $serpapiSecret
    New-Item -ItemType Directory -Force -Path $serpapiDir | Out-Null
    Assert-SerpApiStorePath $serpapiKeyFile
    # CreateNew also refuses a key created by another setup process while the prompt was open.
    $serpapiStream = [System.IO.File]::Open($serpapiKeyFile, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    $serpapiBytes = [System.Text.Encoding]::UTF8.GetBytes($serpapiEncrypted)
    $serpapiStream.Write($serpapiBytes, 0, $serpapiBytes.Length)
}
finally {
    if ($null -ne $serpapiStream) { $serpapiStream.Dispose() }
    if ($null -ne $serpapiSecret) { $serpapiSecret.Dispose() }
    $serpapiPlain = $null
    $serpapiEncrypted = $null
    $serpapiBytes = $null
}
Write-Output "Saved encrypted SerpApi key to $serpapiKeyFile. Load it in the requesting process and verify a search."
