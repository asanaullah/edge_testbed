	.text
	.align	2
_start:
	li	sp,268435456
	jal	main
_hw_shutdown:
	jal	_hw_shutdown
