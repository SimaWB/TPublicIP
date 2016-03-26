# TPublicIP

Bu bileşen programın çalıştığı PCnin public-real(dış) IPsini tespit etmeye yarar. 
Periyodik olarak belirlenen web adresinden IP adresi alınır ve olay(event) tetiklenir.

### Properties:
- **Interval:** Hangi periyotta(**Dakika** cinsinden) kontrol yapılacak.(Varsayılan olarak 15 dk'dır)
- **Link:** Hangi web adresinden IP adresi kontrolü yapılacak. (Güvenli web adresi-HTTPS kullanılacaksa PC'de [OpenSSL](https://www.openssl.org/) kurulu olması gerekir. Yada DLL'lerinin programınızla aynı klasörde olması gerekir)

### Events:
- **OnGetIP(Sender: TObject; const IP: string):** Periyodik kontrolün sonunda geçerli bir IP adresi elde edilirse tetiklenir
- **OnError(Sender: TObject; const ErrorCode: integer):** Kontrol esnasında bir hata meydana geldiğinde tetiklenir. ErrorCode değeri HTTP yanıt kodlarından bir tanesi yada geçersiz IP adresi elde edilmesi durumunda **199**'dur. (Bkz. [HTTP response codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Response_codes))

 Periyodik kontrolü başlatmak için **Start**, sonlandırmak için **Stop** prosedürleri kullanılmalı.
 Çalışma zamanında periyodik kontrollerin yapılıp yapılmadığı **IsActive** özelliği ile kontrol edilebilir.

IP adresi döndüren örnek linkler:
- http://www.myexternalip.com/raw
- https://api.ipify.org
- http://ip.42.pl/raw
- http://www.dubaron.com/myip/

**_[Synapse TCP/IP and serial library](http://synapse.ararat.cz/doku.php/start)_** kullanılmıştır.