data segment
   karakterSayisi db 0    ;karakterSayisi datada binary olarak tutuluyor.
   birinciBasamak db '0'  ;birinciBasamak binary tipinde datada karakter donusumu yapilacagi icin karakter olarak tutulur.
   ikinciBasamak  db '0'  ;ikinciBasamak binary tipinde datada karakter donusumu yapilacagi icin karakter olarak tutulur.
   sayi1 db 0             ;sayi1 tanimliyoruz
   sayi2 db 0             ;sayi2 tanimliyoruz
   kacinciSayi db 1       ;Her turlu enter tusuna basdigimiz icin 1 den baslatiyoruz.
   ilkSayiMesaj db "1.Sayiyi Girin:$"    ;ilk mesaj tanimlama ***Dolar dizinin bittigini belirtir.***
   ikinciSayiMesaj db "2.Sayiyi Girin:$" ;ikinci mesaj tanimlama
   yeniSatir db 10,13,"$" ;ASCII tabloda 10 new line 13 ise girintiyi sifirlamak anlamina gelir.
   islemMesaj db "Toplama icin (1) - Cikarma icin (2) - Carpma icin (3) - Bolme icin (4)",10,13,"Isleminiz:$" ;mesaj tanim.
   sonuc dw ? ;define word boyutunda tanimliyoruz.
   filename db "islemler.txt", 0 ;Filename tanimliyoruz.
   handle dw ? ;Acik tutulacak dosya tanimi 
   data2 db "Islem Basarili" ;Girilecek Veri Tanimi
   data_size=$-offset data2  ;Verinin ne kadarinin yazilacaginin tanimi
   buffer db 10 dup('')      ;Kac byte lik alan olacagi tanimi
ends

stack segment
    dw   128  dup(0)
ends

code segment 
    
sayiDonusumMakro macro hesaplanacakSayi ;parametre tanimlama.
    
    local birBasamakliSayi, ikiBasamakliSayi, sonlandir ;Makroda tekrar etiket kullanimindan hata almamak icin
    
    cmp karakterSayisi,1 ;1 ise  
    je birBasamakliSayi  ;birbasamakliSayiya atla.
    jmp ikiBasamakliSayi ;1 degilse ikibasamakliSayiya atla.
    
birBasamakliSayi:  
    ;Birler basamagi
    sub [birinciBasamak],30h ;ASCII tabloya gore 30h cikardigimizda sayinin kendisi kalir.        
    mov al,[birinciBasamak]  ;AL ye birinci basamak degerini atar.
    mov [hesaplanacakSayi],al;AL deki degeri hesaplanacakSayi parametresine atar.
    jmp sonlandir ;sonlandira atla
    
ikiBasamakliSayi:
    ;Birinci basamak (onlar basamagi)
    sub [birinciBasamak],30h
    mov al,10 ;onlar basamagi oldugu icin 10 ile carpmamiz lazim.AL ye bunun icin 10 degeri atiyoruz.
    mul [birinciBasamak] ;Girilen degerle operandi carpar.
    mov [hesaplanacakSayi],al
    ;Ikinci basamak (birler basamagi)
    sub [ikinciBasamak],30h ;ASCII tabloya gore 30h cikardigimizda sayinin kendisi kalir.        
    mov al,[ikinciBasamak]  ;AL ye ikinci basamak degerini atar.
    add [hesaplanacakSayi],al;birinciBasamak+ikinciBasamak
    jmp sonlandir ;sonlandira atla      
    
    
sonlandir: 
    mov [karakterSayisi], 0    ;Islemlerden sonra temizleme islemi.
    mov [birinciBasamak], '0'  ;Cunku iki basamakli islem yapilacagi zaman
    mov [ikinciBasamak], '0'   ;bu degerlerin temizlenmesi gerek.
    inc kacinciSayi            ;kacinciSayi burada arttirilir.
    

endm ;makroyu bitirir.
  
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax    
    
    call sayilariAl ;Prosedur Cagirma
       
    lea dx,islemMesaj ;dx deki adrese gore
    call mesajYaz     ;Mesaj yazdirma prosedur cagirma. 
    call dortIslem
    
    ;Sonuc degisken degeri yazilmali
    cmp sonuc,10
    jb birBasamakli;sonuc<10 ise atla.
    cmp sonuc,100
    jb ikiBasamakli;sonuc<100 ise atla.
    cmp sonuc,1000
    jb ucBasamakli;sonuc<1000 ise atla.
    cmp sonuc,10000
    jb dortBasamakli;sonuc<10000 ise atla.


birBasamakli:
    mov ax,[sonuc];bir basamak AL de
    add al,30h ;ASCII koduna cevirme.
    call karakterYazdir
jmp bitir
ikiBasamakli:
    mov ax,[sonuc]
    mov bl,10
    div bl ;sonuc al de kalan ah da
    ;ornek 23/10 al=2 ah=3 boyle saklanir.
  ;ilk basamak yaz
    add al,30h ;ASCII koduna cevir
    push ax ;stack'e veri yazdiriyoruz.Anlik veri saklar.
    ;karakter yazdirma
    mov dl,al
    mov ah,02h
    int 21h   ;Onceki asamalarda bahsedildi.
  ;ikinci basamak yaz
    pop ax ;stack'ten AX verisini ceker.
    add ah,30h ;30h ASCII tabloya gore eklenerek rakam bulunur.
    ;karakter yazdirma
    mov dl,ah
    mov ah,02h
    int 21h   ;Onceki asamalarda bahsedildi.
jmp bitir



ucBasamakli:;MANTIK ARTIK HEP AYNI SADECE DAHA UZUN
    mov ax,[sonuc]
    mov bl,100
    div bl ;sonuc al de kalan ah da
    ;ornek 234/100 al=2 ah=34
  ;ilk basamak yaz
    add al,30h ;ASCII koduna cevir
    push ax
    ;karakter yazdirma
    mov dl,al
    mov ah,02h
    int 21h                 
  ;ikinci basamak yaz
    pop ax
    mov al,ah ;34 degeri ah da oldugu icin aktarilmali
    mov ah,00h ;ah=0 olmali cunku tasindi
    ;ah=00 al=34 oldu
    mov bl,10
    div bl ;sonuc al de kalan ah da
    ;ornek 34/10 al=3 ah=4
    add al,30h
    push ax
    ;karakter yazdirma
    mov dl,al
    mov ah,02h
    int 21h
  ;ucuncu basamak yaz
    pop ax
    add ah,30h
    ;karakter yazdirma
    mov dl,ah
    mov ah,02h
    int 21h 
jmp bitir                


dortBasamakli:;BURADA BIRAZ FARKLI
    ;4 basamakli bir sayi ****8**** bitte isleme giremez
    ;bu nedenle div dx ax / bx ikilisi ile kullanilacak
    mov dx,0000h
    mov ax,[sonuc]
    mov bx,1000           
    div bx ;sonuc ax de kalan dx de
    ;ornek 2345/1000 ax=2 dx=345
  ;ilk basamak yaz
    add al,30h ;ASCII koduna cevir
    push dx
    ;karakter yazdirma
    mov dl,al
    mov ah,02h
    int 21h                       
  ;ikinci basamak yaz      
    pop dx
    mov ax,dx ;345 degeri dx de oldugu icin ax e aktarilmali
    mov dx,0000h ;dx=0 olmali cunku tasindi
    ;dx=00 ax=345 oldu
    mov bx,100
    div bx ;sonuc ax de kalan dx de       
    ;ornek 345/100 ax=3 dx=45
    add al,30h
    push dx
    ;karakter yazdirma
    mov dl,al
    mov ah,02h
    int 21h
  ;ucuncu basamak yaz
    pop dx
    mov ax,dx ;45 degeri dx de oldugu icin ax e aktarilmali
    mov dx,0000h ;DX=0 olmali cunku tasindi
    ;dx=00 ax=45 oldu
    mov bx,10
    div bx ;sonuc ax de kalan dx de
    ;ornek 45/10 ax=4 dx=5
    add al,30h 
    push dx
    ;karakter yazdirma
    mov dl,al
    mov ah,02h
    int 21h
  ;dorduncu basamak yaz
    pop dx
    add dl,30h ;zaten sonuc dx=0005h seklinde DL desek yeterli
    ;karakter yazdirma
    mov ah,02h
    int 21h
jmp bitir


    
    
 
        
bitir:

    mov ah, 3ch
    mov cx,0
    mov dx, offset filename ;filename degiskenini DX e atar.
    mov ah, 3ch
    int 21h ;dosya olusturma kesmesi icin ayrintili bilgi Kaynakca [7]
    mov handle, ax ;AX deki dosyayi handle degiskenine atar.

    mov bx, handle
    mov dx, offset data2 ;data2 degiskeninindeki degeri DX e atar.
    mov cx, data_size    ;Datanin ne kadarinin yazilacagini belirler, burda hepsini yazar
    mov ah, 40h
    int 21h ;dosyaya yazma kesmesi icin ayrintili bilgi Kaynakca [7] 

    mov al, 0
    mov bx, handle
    mov cx, 0
    mov dx, 7 ;7 byte ileriye   
    mov ah, 42h
    int 21h ;Imlec kesmesi icin ayrintili bilgi Kaynakca [7]

    mov bx, handle
    mov dx, offset buffer ;buffer da kac byte okumasi gerektigi tanimlandi.
    mov cx, 4
    mov ah, 3fh
    int 21h ;dosya okuma kesmesi icin ayrintili bilgi Kaynakca [7]
                                              
    mov bx, handle
    mov ah, 3eh
    int 21h ;dosya kapatma  kesmesi icin ayrintili bilgi Kaynakca [7]
   
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h   

proc dortIslem       
islemAl:
    call karakterOku
    cmp al,31h ;1(Toplama) mi?       
    je toplama
    cmp al,32h ;2(Cikarma) mi?
    je cikarma
    cmp al,33h ;3(Carpma) mu?
    je carpma
    cmp al,34h ;4(Bolme) mu?
    je bolme
    jmp islemAl  ;Sartlar saglanana kadar sor.
    
toplama:
    ;Secilen islem numarasini ekrana yaz
    mov dl,31h ;'1' ASCII tabloya gore 31h
    mov ah,02h
    int 21h ;Kesme Islemi
    ;alt satira gec
    lea dx, yeniSatir
    call mesajYaz ;Hazirda var olan prosedur.
     
    ;Toplama Islemi
    mov ax,0000h ;Buyuk rakamli islemlerden sonra icerisinde veri kalirsa bize problem cikartmamasi icin sifirliyoruz.
    mov al,[sayi1] ;sayi1 i AL'ye at
    add al,[sayi2] ;sayi2 yi AL'deki sayi ile topla
    mov [sonuc],ax ;AX deki sonucu "sonuc" degiskenine at.
    
    jmp son

cikarma:
     
    ;Secilen islem numarasini ekrana yaz
    mov dl,32h ;'2' ASCII tabloya gore 32h
    mov ah,02h
    int 21h ;Kesme Islemi
    ;alt satira gec
    lea dx, yeniSatir
    call mesajYaz ;Hazirda var olan prosedur.
     
     ;Cikarma Islemi
     mov al,sayi1 ;sayi1 AL ye at.
     cmp al,sayi2 ;AL deki degeri sayi2 ile karsilastir.
     jb negatifSayi ;Sonuc negatiftir.
     mov ax,0000h ;Sonuc pozitiftir.
     mov al,[sayi1] ;Sayi1 AL ye at.
     sub al,[sayi2] ;sayi1-sayi2
     mov [sonuc],ax
     jmp pozitifSayi


negatifSayi:
    mov ax,0000h;Buyuk rakamli islemlerden sonra icerisinde veri kalirsa bize problem cikartmamasi icin sifirliyoruz.
    mov al,[sayi2];sayi2 yi AL ye at.
    sub al,[sayi1];sayi2-sayi1
    mov [sonuc],ax ;Degeri sonuca ata.
    ;ekrana (-) yazmasi lazim
    mov dl,'-'
    mov ah,02h
    int 21h    ;ekrana (-) yazdirma kesmesi.Kaynakca[7]
     
pozitifSayi: 
    
jmp son
carpma:

    ;Secilen islem numarasini ekrana yaz
    mov dl,33h ;'3' ASCII tabloya gore 33h
    mov ah,02h
    int 21h ;Kesme Islemi
    ;alt satira gec
    lea dx, yeniSatir
    call mesajYaz ;Hazirda var olan prosedur.
    
    ;Carpma Islemi
    mov ax,0000h;Buyuk rakamli islemlerden sonra icerisinde veri kalirsa bize problem cikartmamasi icin sifirliyoruz.
    mov al,[sayi1] ;sayi1 i AL ye at.
    mul [sayi2] ;AL deki degeri sayi2 ile carp AX e at.
    mov [sonuc],ax ;AX teki sonucu "sonuc" degiskenine at.
    
    jmp son
bolme:

    ;Secilen islem numarasini ekrana yaz
    mov dl,34h ;'4' ASCII tabloya göre 34h
    mov ah,02h
    int 21h ;Kesme Islemi
    ;alt satira gec
    lea dx, yeniSatir
    call mesajYaz ;Hazirda var olan prosedur.
   
    ;Bolme Islemi
    mov al,sayi1
    cmp al,sayi2
    jb islemAl
    
    mov ax,0000h;Buyuk rakamli islemlerden sonra icerisinde veri kalirsa bize problem cikartmamasi icin sifirliyoruz.    
    mov al,[sayi1];sayi1 i AL'ye at.
    div [sayi2]  ;sayi1/sayi2
    mov ah,00h ;Kalan lazim degil.
    mov [sonuc],ax ;AX teki sonucu "sonuc" degiskenine at.
       
    jmp son 
 
 
son:

ret
endp



proc sayilariAl
    mov dx,offset ilkSayiMesaj ;dx deki adrese gore mesaji yaz.Kaynakca[7]
    call mesajYaz    


oku:
    call karakterOku ;Proseduru cagirma                                        
    cmp al,08h       ;Backsspace mi diye karsilastir.
    je backspace     ;Backspace etiketine atla.
    cmp al,0Dh       ;Enter mi diye karsilastir.
    je enter         ;Enter etiketine atla.
    cmp al,30h       ;ASCII kodu 30h-39h arasinda olmalidir.
    jb oku           ;Kosullu atlama komutu.Kucuk degilse  
    cmp al,39h       ;ASCII kodu 30h-39h arasinda olmalidir.
    ja oku           ;Kosullu atlama komutu.Buyukse.
    
    jmp sayiGirildi  ;Tum kosullar saglandigi icin sayi girilir.
    
    
backspace:
    
    cmp [karakterSayisi],0  ;Karakter sayisi sifir mi?
    je oku           ;sifirsa tekrar karakter oku
    dec [karakterSayisi] ;Buraya geldiyse demekki bir karakter var karakteri bir azalt.
    call karakterTemizle ;karakterTemizle etiketini cagir.
    cmp karakterSayisi, 1 ;Temizlendigi halde karakter sayisi 1 ise demekki bu iki basamakli bir sayi.
    je ikinciBasamakTemizle ;Yukaridaki esitlik saglandigi zaman kalan basamagi temizlemek icin bu etikete git. 
    cmp karakterSayisi, 0   ;Karakter sayi sifirsa bir basamakli sayi girilmistir.
    je birinciBasamakTemizle ;Yukaridaki kosul saglandiginda bu etikete git.
    
birinciBasamakTemizle:
    mov birinciBasamak,'0'
    
    
ikinciBasamakTemizle:    
    mov ikinciBasamak,'0'
    
    jmp oku   ;okuya atla
    
enter:
    cmp [karakterSayisi], 0 ;Karakter var mi?
    je oku                  ;Yoksa okuya don
    lea dx,yeniSatir        ;yeniSatirin baslangic adresini al
    call mesajYaz           ;Bu fonksiyonu cagir.
    jmp sayiDonusum         ;Var ise sayiDonusume git.             
                                           
sayiGirildi:  
    cmp [karakterSayisi], 0 ;sifir ise bir basamak
    je basamakBir           ;evet bir basamaga git
    cmp [karakterSayisi], 1 ;1 ise iki basamak
    je basamakIki           ;evet iki basamaga git
    jmp oku                 ;max iki basamak girilecegi icin okuya don

basamakBir:
    mov [birinciBasamak], al ;AL icerisinde olan degeri buraya aktar.
    inc [karakterSayisi] ;Karakter aktardigimiz icin bir arttir.
    call karakterYazdir  ;Degeri ekrana yazdir.
    jmp oku              ;Kosulsuz olarak okuya don
                         ;Cunku yazdiktan sonra belki ikinci deger girilmek istenebilir ya da enter basilmak istenebilir.   

basamakIki:
    mov [ikinciBasamak], al ;AL icerisinde olan degeri buraya aktar.
    inc [karakterSayisi] ;Karakter aktardigimiz icin bir arttir.
    call karakterYazdir  ;Degeri ekrana yazdir.
    jmp oku              ;Kosulsuz olarak okuya don
                         ;Cunku yazdiktan sonra enter basilmak istenebilir. 

sayiDonusum:
    cmp [kacinciSayi],1 ;Eger 1 ise  ;NOT:kacinciSayi makro icerisinde arttirilacak.
    je ilkSayi          ;Buraya atla
    jmp ikinciSayi      ;Sart saglanmazsa buraya atla

ilkSayi:
    sayiDonusumMakro sayi1
    lea dx,ikinciSayiMesaj ;Baslangic adresi al
    call mesajYaz          ;mesajyaza git
    jmp oku    
ikinciSayi:
    sayiDonusumMakro sayi2
    ret
endp


proc mesajYaz
    ;dx de dizi adresi olmali.
    mov ah,09h
    int 21h
    ret
endp    
    
    
proc karakterOku;Karakter Okuma islemi  Kaynakca[7]  
    mov ah,07h 
    int 21h ;Klavyeden Okunan Deger AL icerisine atilir.AL=karakter  
    ret     
endp
    
proc karakterYazdir ;Karakter yazdirma islemi Kaynakca [7]
    mov dl,al 
    mov ah,02h
    int 21h ;DL icerisindeki karakter ekrana yazdirilir.Yazdirilan karakter AL icerisine de aktarilir.
    ret
endp
      
      
proc karakterTemizle 
    ;backspace karakteri ile bir karakter geri gel 
    mov dl,08h  ;DL icine deger aktarip 
    mov ah,02h  ;Karakteri
    int 21h     ;Ekrana yazdiriyoruz. 
    ;bosluk karakteri ile silinmis goruntu olustur.
    mov dl,' ' ;bosluk karakterini
    mov ah,02h;Ekrana yazdirir.
    int 21h
    ;backspace karakteri ile bir karakter geri gel
    ;imlec sagda kaldigi icin birkez daha sola kaydir. 
    mov dl,08h  ;DL icine deger aktarip 
    mov ah,02h  ;Karakteri
    int 21h     ;Ekrana yazdiriyoruz.
    
          
    ret
endp
    
      
      
    
     
ends

end start ; set entry point and stop the assembler.
