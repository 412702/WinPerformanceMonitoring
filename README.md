# WinPerfomanceMonitoring

功能：用powershell对windows进行逻辑内核，内存使用情况进行监控，每2s刷新一次，结构非常简单

Function: use powershell to monitor the logical kernel and memory usage of windows, refresh every 2s, and the structure is very simple

## 首先看一下效果，如下图

![image](https://user-images.githubusercontent.com/44056689/206975353-9b178cf3-6c58-4620-8f54-ecca8645014f.png)


## 为什么要搞这个小不点玩意？

因为实验需要，要用到windows来跑程序，对于自己电脑，有个任务管理器还好说，但是对于远程windows服务器，有的时候不是很方便使用远程桌面（因为写代码大多数情况下不需要登录到远端，本地IDE通过SSH连接远程环境就可以使用远程算力资源），为了不再麻烦操作，就直接简单用Powershell脚本写了个监控面板，简单，用起来还凑合

代码如下

```powershell
# 获取 可用内存
function free_physics_ram(){
	$ops = Get-WmiObject -Class Win32_OperatingSystem
	#"可用内存(MB): {0}" -f ([math]::round($ops.FreePhysicalMemory / 1kb, 2))
	$ops =([math]::round(($ops.FreePhysicalMemory / (1mb)), 2))
	return @($ops)
}

 
# 获取CPU使用率
function cpu_percent(){
	$cpu = Get-WmiObject -Class Win32_Processor 
	$Havecpu = $cpu.LoadPercentage 
	return @($Havecpu)
}

# 获取内存使用率
function phy_percent(){
	$men = Get-WmiObject -Class win32_OperatingSystem
	$Permem =  ((($men.TotalVisibleMemorySize-$men.FreePhysicalMemory)/$men.TotalVisibleMemorySize)*100)
	return @([math]::round($Permem, 2))
}

$counters=new-object 'System.Diagnostics.PerformanceCounter[]' ([System.Environment]::ProcessorCount)
for($i=0;$i -lt $counters.Length;$i++){
	$counters[$i]=new-object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time",$i)
}


while(1){
	$c_list = @()
	# 保留一位小数，转为字符串，左边填充到长度为3
	foreach($c in $counters){
		$c_list += ([string]([math]::round(($c.NextValue()), 1))).PadLeft(4)
	}

	$c_length = $c_list.length

	$free_physics_ram = free_physics_ram
	$cpu_percent = cpu_percent
	$Ram_percent = phy_percent

	$row_bar = "="*64

	# Overall System Status
	Clear-Host
	# [Console]::Out.Flush() 
	Write-Output $row_bar
	Write-Output ("|"+ "Overall System Status".PadLeft(43).PadRight(62)+"|")
	Write-Output $row_bar
	
	foreach($i in 1..($c_length/8)){
		$data_list = $c_list[($i-1)..($i+6)]
		$row = $data_list -join " || "
		$row = "| " + $row + " |"
		Write-Output $row
		Write-Output $row_bar
	}


	Write-Output ("|"+ "CPU_Logical_Core: $c_length".PadLeft(43).PadRight(62)+"|")
	Write-Output ("|"+ "CPU_Used_Percent: $cpu_percent %".PadLeft(43).PadRight(62)+"|")
	Write-Output ("|"+ "RAM_Used_Percent: $Ram_percent %".PadLeft(43).PadRight(62)+"|")
	Write-Output ("|"+ "Free_Physics_RAM: $free_physics_ram GB".PadLeft(43).PadRight(62)+"|")

	Write-Output $row_bar
	Start-Sleep 2
}
```
