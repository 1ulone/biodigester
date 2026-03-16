# SMART BIODIGESTER
Proyek IoT Smart Biodigester bertujuan utama untuk mengendalikan dan memantau operasional 
alat biodigester secara terintegrasi melalui perangkat mobile. Sistem ini melacak berbagai parameter penting, mulai dari suhu, pH, tekanan, hingga kadar CH4, di mana data dari setiap sensor ditransmisikan menggunakan broker MQTT. Selain fungsionalitas pemantauan, Smart Biodigester ini juga dilengkapi dengan fitur analisis tingkat lanjut yang didukung oleh model AI _gpt-oss-120b_ melalui integrasi API GROQ.
# Arsitektur
![[biodigester.drawio.png|599]]
# Prerequisite
1. Docker : https://docs.docker.com/engine/install/
2. Flutter SDK : https://docs.flutter.dev/install
# Installasi
Buka terminal lalu pull repository ini.
```
git pull https://github.com/1ulone/biodigester
```

# Usage
Untuk mengaktifkan *web-middleman* masuklah kedalam folder `\bio-middleman` pada terminal menggunakan command `cd \middleman\bio-middleman`
eksekusi
```
Docker compose up -d --build
```
Untuk mengaktifkan aplikasi flutter di localhost maka masuklah kedalam folder `\pbl_biodigester` pada terminal menggunakan command `cd \pbl_biodigester` (gunakan `cd ../` jika sebelumnya mengaktifkan middleman).
Eksekusi command berikut di terminal: 
```
flutter devices
```
lalu cari device yang diinginkan (recommended untuk menggunakan device web).
```
flutter run -d <device_id>
```
Terakhir ada file *.ino* di root projek, Buka file tersebut dalam arduino IDE. untuk WIFI nya sesuaikan dengan WIFI anda.

# Teori
Sensor yang akan digunakan:

- SENSOR SUHU TAHAN AIR DS18B20 (Resistor +4.7k)
    
- Gravity: Sensor pH Analog
    
- SENSOR TEKANAN UDARA MPX5700DP MPX5700 MPX 5700 DP
    
- Sensor Gas Alam Metana NGM2611-E13 dengan Filter Pra-Kalibrasi
    

Apa yang dilakukan dan dihasilkan oleh setiap sensor:

##### Suhu

Sensor ini akan mengukur Lingkungan Termal dari campuran tinja tersebut, <u>Tapi kenapa?</u>, sederhananya _Metabolisme Bakteri_ sangat ditentukan oleh suhu. Karena ini akan digunakan oleh petani, di dalam rumah mereka. maka bisa jadi ada kasus di mana suhunya dingin (banyak AC) atau lebih hangat. Bakteri yang diharapkan tumbuh diklasifikasikan sebagai Mesofilik (Tumbuh paling baik di lingkungan menengah 20 - 45 C, Optimal pada 37 C).

Penggunaan Sensor DS18B20 akan secara otomatis menampilkan suhu yang benar (karena sudah dikalkulasi sebelumnya).

Keluaran Terbaik : 30 - 37 Celcius

Keluaran Terburuk : Di bawah 20 C atau Di atas 45 C, Atau fluktuasi mendadak lebih dari 2 / 3 C per hari.

#### PH (Keasaman)

Tentu saja sensor pH akan menghasilkan nilai Keasaman mentah dari lumpur tersebut, sama seperti suhu. Sensor akan dicelupkan (tidak seluruhnya) ke dalam campuran tinja. Pertanyaan yang sama seperti sebelumnya, <u>Untuk apa?</u>, sensor ini akan memantau _Konsentrasi ion Hidrogen_ (entah apa itu, saya rasa itu cuma kata-kata keren untuk keasaman atau semacamnya), Pencernaan Anaerobik yang merupakan proses di mana bakteri memecah campuran tinja dan mengubahnya menjadi gas terjadi secara bertahap (hidrolisis, asidogenesis, asetogenesis, dan metanogenesis). Jika bakteri penghasil asam bekerja lebih cepat daripada bakteri penghasil metana, asam lemak volatil akan menumpuk, sehingga menurunkan pH. Kondisi ini dapat membunuh _metanogen_, yaitu bakteri yang sebenarnya menghasilkan Metana (Gas).

Sensor akan mengeluarkan tegangan analog (0V - 5V), Kita harus benar-benar menghitung sesuatu dan menerjemahkannya ke dalam nilai pH. Yang menggunakan persamaan ini:

##### $pH = 3.5 * Vout + Offset$

*Offset: Variabel kalibrasi manual. Dimulai pada 0.00. Jika Anda menguji larutan penyangga (buffer) pH 7.0 dan keluarannya 6.8, offset Anda menjadi +0.20.

V<small>out</small> Merujuk pada tegangan keluaran (ya pastilah) tetapi terkadang mikrokontroler meskipun mengatakan (5V) ia membatasi dirinya pada keluaran 3.0V, jadi sebelum itu jika pH-nya tidak akurat, kita dapat menggunakan persamaan lain untuk mendapatkan nilai V<small>out</small>:

##### [v_eq] $Vout = RawAnalogOutput * (\frac{5.0}{1024.0})$ 

Keluaran Terbaik : 6.8 - 7.2 pH

Keluaran Terburuk : Di bawah 6.5 pH (berhenti menambahkan lebih banyak tinja ke dalam biodigester. biarkan metanogen mengonsumsi kelebihan asam, jadi tunggu saja)

#### Tekanan

Ini adalah yang paling penting. Kita dapat menghitung berapa banyak volume gas yang dihasilkan dan jumlah "bahan bakar" yang tersisa.

Sensor ini mengeluarkan Tegangan analog linier (0.2V hingga 4.7V), Kita dapat menggunakan persamaan lain untuk mengubah tegangan tersebut menjadi kilopascal (kPa). Persamaannya adalah:

##### $Pkpa = \frac{Vout - 0.2}{0.006429}$

Sekali lagi V<small>out</small> dapat dihitung melalui Persamaan [v_eq]

Keluaran Terbaik : 101.3 kPa

Keluaran Terburuk : Di atas 101.3 kPa, karena gas menumpuk, tangkinya bisa meledak (kurasa begitu).

#### Metana (CH4)

Karena biogas memiliki konsentrasi metana di dalamnya. Campuran tersebut utamanya terdiri dari metana (CH4) dan karbon dioksida (CO2). Dan hanya metana yang dapat digunakan sebagai bahan bakar. Sensor ini akan memastikan kualitas Biogas.

Jadi keluaran sensor akan dibaca secara langsung sebagai persentase (%), atau sebagai _parts per million_ (ppm) metana.

Keluaran Terbaik : 50% hingga 75% CH4

Keluaran Terburuk : Di bawah 50% CH4, Gas tersebut akan sedikit sulit terbakar, ia akan menyala tetapi, apinya relatif kecil atau sangat mudah padam. Penyebabnya bisa jadi karena kondisi pH atau suhu yang buruk.

### Monitor Aplikasi

Hal utama yang akan ditampilkan aplikasi adalah:

- Tombol Buka / Tutup (untuk membuka/menutup katup)
    
- Menampilkan barisan sisa bahan bakar (dalam gaya _bar_)
    
- Menampilkan analisis pemutusan (_cutoff_) cepat
    

Perilaku:

Tombol Utama akan digunakan untuk membuka / menutup katup dengan mengirimkan `{'toggle':0/1}` ke postgresql

Bar sisa bahan bakar akan diperoleh dengan hanya menggunakan Sensor Tekanan, kita akan menghitung volume aktual bahan bakar yang tersisa dengan menggunakan persamaan ini:

#### $Vbio = Vheadspace * (\frac{PressureValue}{101.325}) * (\frac{273.15}{273.15+Temperature})*(\frac{CH4}{100})$

- V<small>headspace</small> adalah volume fisik statis dari zona gas kosong di dalam tangki
    
- PressureValue adalah nilai yang kita dapatkan dari Sensor MPX5700AP dalam kiloPascal
    
- Temperature adalah nilai yang kita dapatkan dari Sensor Suhu dalam celcius (ya pastilah)
    
- CH4 adalah nilai yang kita dapatkan dari Sensor CH4 (Nilai Berkisar dari 0 hingga 100)
    
- 101.325 adalah konstanta untuk tekanan atmosfer dalam kiloPascal
    
- 273.15 adalah konstanta konversi nol mutlak untuk Kelvin# biodigester
Repo PBL Biodigester PPI Internal, dari Web Middleman sampai Aplikasi Monitoring berbasis Flutter
