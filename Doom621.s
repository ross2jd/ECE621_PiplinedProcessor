	.file	1 "Doom621.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.text
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$fp,56,$31		# vars= 32, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-56
	sw	$31,52($sp)
	sw	$fp,48($sp)
	move	$fp,$sp
	sb	$0,32($fp)
	sb	$0,33($fp)
	li	$2,5			# 0x5
	sw	$2,36($fp)
	li	$2,9			# 0x9
	sw	$2,40($fp)
	sw	$0,44($fp)
	li	$2,3			# 0x3
	sw	$2,16($fp)
	li	$2,12			# 0xc
	sw	$2,20($fp)
	li	$2,15			# 0xf
	sb	$2,32($fp)
	li	$2,2			# 0x2
	sb	$2,33($fp)
	addiu	$4,$fp,36
	addiu	$5,$fp,40
	addiu	$3,$fp,44
	addiu	$2,$fp,32
	move	$6,$3
	move	$7,$2
	jal	shift
	nop

	addiu	$2,$fp,36
	sw	$2,24($fp)
	addiu	$2,$fp,40
	sw	$2,28($fp)
	lw	$4,24($fp)
	lw	$5,28($fp)
	jal	swap
	nop

	lw	$2,24($fp)
	lw	$2,0($2)
	sw	$2,36($fp)
	lw	$2,28($fp)
	lw	$2,0($2)
	sw	$2,40($fp)
	j	.L2
	nop

.L3:
	lw	$3,44($fp)
	lw	$2,40($fp)
	subu	$2,$3,$2
	sw	$2,44($fp)
	lw	$2,40($fp)
	addiu	$2,$2,-1
	sw	$2,40($fp)
.L2:
	lw	$2,40($fp)
	bgez	$2,.L3
	nop

	lw	$2,40($fp)
	slt	$2,$2,3
	beq	$2,$0,.L4
	nop

	li	$2,48			# 0x30
	sw	$2,40($fp)
.L4:
	lw	$3,36($fp)
	lw	$2,40($fp)
	addu	$3,$3,$2
	lw	$2,44($fp)
	addu	$2,$3,$2
	move	$sp,$fp
	lw	$31,52($sp)
	lw	$fp,48($sp)
	addiu	$sp,$sp,56
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.align	2
	.globl	swap
	.set	nomips16
	.set	nomicromips
	.ent	swap
	.type	swap, @function
swap:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$5,20($fp)
	lw	$2,16($fp)
	lw	$2,0($2)
	sw	$2,0($fp)
	lw	$2,20($fp)
	lw	$3,0($2)
	lw	$2,16($fp)
	sw	$3,0($2)
	lw	$2,20($fp)
	lw	$3,0($fp)
	sw	$3,0($2)
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	swap
	.size	swap, .-swap
	.align	2
	.globl	shift
	.set	nomips16
	.set	nomicromips
	.ent	shift
	.type	shift, @function
shift:
	.frame	$fp,40,$31		# vars= 16, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$fp,32($sp)
	move	$fp,$sp
	sw	$4,40($fp)
	sw	$5,44($fp)
	sw	$6,48($fp)
	sw	$7,52($fp)
	lw	$2,52($fp)
	addiu	$2,$2,1
	sw	$2,52($fp)
	lw	$2,52($fp)
	lbu	$2,0($2)
	sb	$2,16($fp)
	lw	$2,52($fp)
	addiu	$2,$2,-1
	sw	$2,52($fp)
	lw	$2,52($fp)
	lbu	$2,0($2)
	sb	$2,24($fp)
	li	$2,2			# 0x2
	sw	$2,20($fp)
	lbu	$3,16($fp)
	lw	$2,20($fp)
	slt	$2,$2,$3
	bne	$2,$0,.L7
	nop

	lw	$2,44($fp)
	lw	$3,0($2)
	lw	$2,20($fp)
	sll	$3,$3,$2
	lw	$2,44($fp)
	sw	$3,0($2)
.L7:
	lw	$2,40($fp)
	lw	$2,0($2)
	sra	$3,$2,1
	lw	$2,40($fp)
	sw	$3,0($2)
	addiu	$2,$fp,24
	lw	$4,40($fp)
	lw	$5,44($fp)
	lw	$6,48($fp)
	move	$7,$2
	jal	doop
	nop

	move	$sp,$fp
	lw	$31,36($sp)
	lw	$fp,32($sp)
	addiu	$sp,$sp,40
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	shift
	.size	shift, .-shift
	.align	2
	.globl	doop
	.set	nomips16
	.set	nomicromips
	.ent	doop
	.type	doop, @function
doop:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	sw	$6,16($fp)
	sw	$7,20($fp)
	lw	$2,8($fp)
	lw	$3,0($2)
	lw	$2,12($fp)
	lw	$2,0($2)
	mul	$3,$3,$2
	lw	$2,20($fp)
	lbu	$2,0($2)
	addu	$3,$3,$2
	lw	$2,16($fp)
	sw	$3,0($2)
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	doop
	.size	doop, .-doop
	.ident	"GCC: (Sourcery G++ Lite 2011.03-52) 4.5.2"
