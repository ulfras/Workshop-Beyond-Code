# bugs/

Satu file per bug. Salin `_template.md`, beri nama sesuai bug (misalnya `tombol-lanjut-abu.md`), dan simpan screenshot di folder ini dengan nama yang sama.

```bash
cp bugs/_template.md bugs/tombol-lanjut-abu.md
xcrun simctl io booted screenshot bugs/tombol-lanjut-abu.png
```

Di prompt cukup tulis: "Perbaiki bug di bugs/tombol-lanjut-abu.md. Tulis test yang gagal dulu."
