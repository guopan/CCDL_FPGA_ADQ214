# CCDL_FPGA_ADQ214

Implement FFT algorithm in ADQ214 FPGA #1.
And also the power spectrum accumulation, Peak detection algorithm.

##目录结构如下：
```
├─implementation  
│  └─xilinx  
│      ├─constraints  
│      ├─ipcore_dir  
│      ├─iseconfig  
│      ├─isim  
│      ├─logfiles  
│      ├─netgen  
│      ├─scripts  
│      ├─xlnx_auto_0_xdb  
│      ├─xst  
│      ├─_ngo  
│      └─_xmsgs  
├─ngc  
└─source  
    ├─Matlab_verify  
    └─ipcore_dir
```

Git仓库位于source文件夹、

# 使用方法

1. 将ADQ214开发包复制到适当位置，按照User Guide文件“11-0724_UsersGuide_ADQ_V5_DevKit.pdf”中的说明，利用ADQ214_devkit.tcl创建ISE工程。
2. 从Github网站clone项目文件到source文件夹，执行其中的Add_NewSource_Files.tcl，添加新的源文件到工程之中。
3. Regenerate All cores，其间每个IP core会弹出缺失xxx_synth.vhd的对话框，选择Yes继续。

# 开发软件版本：

ISE 14.7 （会影响其中的IP core 生成的版本）
在低版本的ISE中，Regenerate Al IPl cores可能会不成功。
