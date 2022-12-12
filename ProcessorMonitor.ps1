
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
		$c_list += "$([math]::round(($c.NextValue()), 1))%".PadLeft(5)
	}

	$c_length = $c_list.length

	$free_physics_ram = free_physics_ram
	$cpu_percent = cpu_percent
	$Ram_percent = phy_percent

	$row_bar = "="*72

	# Overall System Status
	Clear-Host
	# [Console]::Out.Flush() 
	Write-Output $row_bar
	Write-Output ("|"+ "Overall System Status".PadLeft(47).PadRight(70)+"|")

	Write-Output $row_bar
	foreach($i in 1..($c_length/8)){
		$data_list = $c_list[($i-1)..($i+6)]
		$row = $data_list -join " || "
		$row = "| " + $row + " |"
		Write-Output $row
		Write-Output $row_bar
	}


	Write-Output ("|"+ "CPU_Logical_Core: $c_length".PadLeft(47).PadRight(70)+"|")
	Write-Output ("|"+ "CPU_Used_Percent: $cpu_percent %".PadLeft(47).PadRight(70)+"|")
	Write-Output ("|"+ "RAM_Used_Percent: $Ram_percent %".PadLeft(47).PadRight(70)+"|")
	Write-Output ("|"+ "Free_Physics_RAM: $free_physics_ram GB".PadLeft(47).PadRight(70)+"|")

	Write-Output $row_bar
	Start-Sleep 2
}