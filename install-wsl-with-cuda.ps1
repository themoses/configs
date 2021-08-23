# PowerShell Script to install WSL in Windows with CUDA

### Define functions ###

function FirstPart {

    # Check Virtualization state
    $virtualizationState = Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online

    if ($virtualizationState.State -eq "Disabled") {
        Write-Host "Virtualization is not enabled, enabling..."
        dism.exe /Online /Enable-Feature /FeatureName:VirtualMachinePlatform /all /norestart
    }

    # Check Hyper-V state
    $hypervState = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online

    if ($hypervState.State -eq "Disabled") {
        Write-Host "Hyper-V is not enabled, enabling..."
        dism.exe /Online /Enable-Feature /FeatureName:Microsoft-Hyper-V /all /norestart

        # disable hyper-v as standard hypervisor so VirtualBox will not break
        bcdedit /set hypervisorlaunchtype auto
    }

    # Check WSL
    $wslState = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    if ($wslState.State -eq "Disabled") {
        Write-Host "WSL is not installed, installing..."
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    }

    # Install Nvidia drivers if a gpu is present
    Write-Host "Dowloading NVIDIA CUDA Drivers"
    if($isQuadroModel){
        $dlpath = "https://developer.nvidia.com/47121-quadro-win10-dch-64bit-international"
    }
    else {
        $dlpath = "https://developer.nvidia.com/47121-gameready-win10-dch-64bit-international"
    }
    
    Invoke-WebRequest -Uri $dlpath -OutFile "C:\Temp\nvidiadriver.exe"
    Start-Process -FilePath "C:\Temp\nvidiadriver.exe"

    New-Item -Path "C:\" -Name "temp" -ItemType "directory" -ErrorAction SilentlyContinue
    New-Item -Path "C:\temp" -Name "continue" -ItemType "file" -ErrorAction SilentlyContinue
    Write-Host "Please restart your computer now and execute the script again"

}

function SecondPart {
    Remove-Item -Path "C:\Temp\continue" -Force -ErrorAction SilentlyContinue

    # Install Kernel Patch
    Write-Host "Dowloading Kernel Patch"
    Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile "C:\Temp\wsl_update_x64.msi"

    Write-Host "Installing Kernel Patch..."
    Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Temp\wsl_update_x64.msi /quiet'

    if($?) {
        Write-Host "Successful"
    }
    else {
        Write-Host "Something went wrong."
    }

    # Set default to WSL2
    wsl --set-default-version 2

    # download 18.04
    Write-Host "Downloading 18.04 image"
    Invoke-WebRequest -Uri "https://aka.ms/wsl-ubuntu-1804" -OutFile "C:\Temp\Ubuntu.appx" -UseBasicParsing

    # Install 18.04
    Add-AppxPackage "C:\Temp\Ubuntu.appx"

    # Download and Install Docker for Windows
    Write-Host "Dowloading Docker for Windows"
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/stable/amd64/Docker%20Desktop%20Installer.exe" -OutFile "C:\Temp\DockerInstaller.exe"


    New-Item -Path "C:\temp" -Name "finish" -ItemType "file" -ErrorAction SilentlyContinue

    Start-Process -FilePath "C:\Temp\DockerInstaller.exe" -ArgumentList "install"  
}

function ThirdPart {
    # TODO: set proxy within docker and DNS servers manually

   # Set docker config
   $dockerConfig = '{"credsStore":"desktop","proxies":{"default":{"httpProxy":"INSERTPROXY","httpsProxy":"INSERTPROXY","noProxy":"host.docker.internal,localhost,127.0.0.1"}}}'

   Set-Content -Path "C:\Users\$env:USERNAME\.docker\config.json" -Value $dockerConfig
}

function prechecks {

    # Check if we are running elevated

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "Not executed as Administrator. Exiting"
        exit 1
    }

    #$sysInfo = systeminfo

    # Check Windows Version

    $buildNumber = Get-WmiObject -Class win32_OperatingSystem | Select-Object BuildNumber

    if ($buildNumber.BuildNumber -lt 18363) {
        Write-Host "Windows Version too low. Exiting"
        exit 1
    }

    # Check GPU
    $hasNvidiaGPU = false
    $isQuadroModel = false

    $gpus = Get-WmiObject win32_VideoController
    if ($gpus.Description -Match "NVIDIA"){
        $hasNvidiaGPU = true

        if ($gpus.Description -Match "Quadro"){
            $isQuadroModel = true
        }

    }
}

### Run everything ###

prechecks

if (Test-Path -Path "C:\Temp\continue"){
    SecondPart
}
elseif (Test-Path -Path "C:\Temp\finish") {
    ThirdPart
} {
    FirstPart
}
