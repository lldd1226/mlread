# 定义需要同步的多对文件夹（源， 目标）
$folderPairs = @(
    @("D:\马恩列总装\MARX-ZH-CN.github.io1\docs\MEA","D:\马恩列总装\mlread\docs\MEA"),
    @( "D:\马恩列总装\MARX-ZH-CN.github.io1\docs\MEW","D:\马恩列总装\mlread\docs\MEW" ),
    @("D:\马恩列总装\MARX-ZH-CN.github.io1\docs\MEW-ZH","D:\马恩列总装\mlread\docs\MEW-ZH" ),
@("D:\马恩列总装\MARX-ZH-CN.github.io1\docs\LENIN" "D:\马恩列总装\mlread\docs\LENIN"),
@("D:\马恩列总装\MARX-ZH-CN.github.io1\docs\VIL","D:\马恩列总装\mlread\docs\VIL"),
@("D:\马恩列总装\MARX-ZH-CN.github.io1\en","D:\马恩列总装\mlread\en"),
)

$watchers = @()
$action = {
    param($sourcePath, $targetPath)
    $source = Get-Item $sourcePath
    $target = Get-Item $targetPath
    # 简易冲突处理：只同步最后修改时间更新的文件
    if ($source.LastWriteTime -gt $target.LastWriteTime) {
        robocopy $sourcePath $targetPath /XO /R:1 /W:1 /NP
        Write-Host "$(Get-Date) [同步] $sourcePath -> $targetPath"
    }
}

foreach ($pair in $folderPairs) {
    $source, $target = $pair
    $watcher = New-Object IO.FileSystemWatcher $source, '*'
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    Register-ObjectEvent $watcher 'Changed' -Action { & $action $source $target }
    Register-ObjectEvent $watcher 'Created' -Action { & $action $source $target }
    Register-ObjectEvent $watcher 'Deleted' -Action { & $action $source $target }
    $watchers += $watcher
    Write-Host "开始监控: $source"
}

Write-Host "所有文件夹监控已启动，按 Ctrl+C 退出。" -ForegroundColor Green
try { while ($true) { Start-Sleep 1 } } finally { $watchers | ForEach-Object { $_.Dispose() } }