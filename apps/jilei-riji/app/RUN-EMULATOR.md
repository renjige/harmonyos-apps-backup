# 模拟器一键运行（绕过 DevEco 旧包名缓存）

包名必须与 `AppScope/app.json5` 一致：**jlrj.lwl.huawei**

```powershell
cd E:\huawei001-master\apps\jilei-riji\app
.\run-emulator.ps1
```

或手动：

```powershell
$hdc = "E:\software\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe"
$hap = "entry\build\default\outputs\default\entry-default-signed.hap"
& $hdc shell bm uninstall -n com.qingjilei.jileiriji
& $hdc install -r $hap
& $hdc shell aa start -a EntryAbility -b jlrj.lwl.huawei -m entry
```
