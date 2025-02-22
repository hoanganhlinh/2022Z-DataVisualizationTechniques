install.packages("PogromcyDanych")
library(PogromcyDanych)
library(dplyr)
# dodatkowe pakiety
library(tidyr)
library(stringr)

colnames(auta2012)
dim(auta2012)
head(auta2012[,-ncol(auta2012)])
sum(is.na(auta2012))

## 1. Z kt�rego rocznika jest najwi�cej aut i ile ich jest?
auta2012 %>% 
  count(Rok.produkcji, sort = TRUE) %>% 
  head(1)

## Odp: Rocznik: 2011; ilo��: 17418;


## 2. Kt�ra marka samochodu wyst�puje najcz�ciej w�r�d aut wyprodukowanych w 2011 roku?
auta2012 %>% 
  filter(Rok.produkcji==2011) %>% 
  count(Marka, sort = TRUE) %>% 
  head(1)

## Odp: Marka: Skoda;


## 3. Ile jest aut z silnikiem diesla wyprodukowanych w latach 2005-2011?
auta2012 %>% 
  filter(2005 <= Rok.produkcji & Rok.produkcji <= 2011 & Rodzaj.paliwa == "olej napedowy (diesel)") %>% 
  count()

## Odp: 59534


## 4. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2011 roku, kt�ra marka jest �rednio najdro�sza?
auta2012 %>% 
  filter(Rok.produkcji == 2011 & Rodzaj.paliwa == "olej napedowy (diesel)") %>% 
  group_by(Marka) %>% 
  summarise(srednia_cena = mean(Cena.w.PLN)) %>% 
  top_n(1)

## Odp: Porsche


## 5. Spo�r�d aut marki Skoda wyprodukowanych w 2011 roku, kt�ry model jest �rednio najta�szy?
auta2012 %>% 
  filter(Marka == "Skoda"& Rok.produkcji == 2011) %>% 
  group_by(Model) %>% 
  summarise(srednia_cena = mean(Cena.w.PLN)) %>% 
  arrange(srednia_cena) %>% 
  head(1)

## Odp: Fabia


## 6. Kt�ra skrzynia bieg�w wyst�puje najcz�ciej w�r�d 2/3-drzwiowych aut, kt�rych stosunek ceny w PLN do KM wynosi ponad 600?
auta2012 %>% 
  filter(Liczba.drzwi == "2/3" & Cena.w.PLN/KM > 600) %>% 
  count(Skrzynia.biegow, sort = TRUE) %>% 
  top_n(1)

## Odp: automatyczna


## 7. Spo�r�d aut marki Skoda, kt�ry model ma najmniejsz� r�nic� �rednich cen mi�dzy samochodami z silnikiem benzynowym, a diesel?
auta2012 %>% 
  filter(Marka == "Skoda" & (Rodzaj.paliwa == "olej napedowy (diesel)" | Rodzaj.paliwa == "benzyna")) %>% 
  group_by(Model, Rodzaj.paliwa) %>% 
  summarise(srednia_cena = mean(Cena.w.PLN)) %>%  
  group_by(Model) %>% 
  mutate(diff = abs(srednia_cena - lag(srednia_cena))) %>% 
  arrange(diff) %>% 
  head(1)

## Odp: Felicia


## 8. Znajd� najrzadziej i najcz�ciej wyst�puj�ce wyposa�enie/a dodatkowe samochod�w marki Lamborghini
ramka <- auta2012 %>% 
  filter(Marka == "Lamborghini") %>% 
  select(Wyposazenie.dodatkowe)
nowa_ramka = separate_rows(ramka, 1, sep= ",") %>% 
  group_by(Wyposazenie.dodatkowe) %>% 
  count() %>% 
  arrange(n)
# najrzadziej wyst�puj�ce wyposa�enie
nowa_ramka %>% 
  arrange(n)
# najcz�ciej wyst�puj�ce wyposa�enie
nowa_ramka %>% 
  arrange(-n)

## Odp: Najcz�ciej: alufelgi, wspomaganie kierownicy, ABS; Najrzadziej: blokada skrzyni bieg�w, klatka;


## 9. Por�wnaj �redni� i median� mocy KM mi�dzy grupami modeli A, S i RS samochod�w marki Audi
auta2012 %>% 
  filter(Marka == "Audi") %>% 
  mutate(X = case_when(str_starts(Model, "A") ~ "A",
                       str_starts(Model, "RS") ~ "RS", 
                       str_starts(Model, "S") ~ "S",
                       TRUE ~ "else")) %>% 
  filter(X == "A" | X == "S" | X == "RS") %>% 
  group_by(X) %>% summarise(meanKM = mean(KM, na.rm = T), medianKM = median(KM, na.rm = T)) %>% 
  mutate(diff = abs(meanKM - medianKM))
  

## Odp: Dla modelu A r�nica wynosi 19.6, dla modelu S 50.0, a dla modelu RS 0.263.


## 10. Znajd� marki, kt�rych auta wyst�puj� w danych ponad 10000 razy. Podaj najpopularniejszy kolor najpopularniejszego modelu dla ka�dej z tych marek.

auta2012 %>% 
  group_by(Marka) %>% 
  count() %>% 
  filter(n > 10000)

def_model_kolor <- function(marka) {
  model = auta2012 %>% 
    filter(Marka == marka) %>% 
    group_by(Model) %>% 
    count() %>% 
    arrange(-n) %>% 
    head(1)
  kolor = auta2012 %>% 
    filter(Marka == marka & Model == model$Model) %>% 
    group_by(Kolor) %>% 
    count() %>% 
    arrange(-n) %>% 
    head(1)
  paste(model$Model, kolor$Kolor)
}

def_model_kolor("Audi")
def_model_kolor("BMW")
def_model_kolor("Ford")
def_model_kolor("Mercedes-Benz")
def_model_kolor("Opel")
def_model_kolor("Renault")
def_model_kolor("Volkswagen")

## Odp: Marka :      Audi       :       BMW       :     Ford        :   Mercedes-Benz  :      Opel        :     Renault     :   Volkswagen
##      Model :       A4        :       320       :     Focus       :     C 220        :      Astra       :     Megane      :     Passat
##      Kolor : czarny-metallic :srebrny-metallic : srebrny-metallic: srebrny-metallic : srebrny-metallic : srebrny-metallic: srebrny-metallic