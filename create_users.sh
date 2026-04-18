#!/bin/bash

#1. Här kontrollerar skriptet att alla som kör användaren är root
#UID 0 är alltid användaren root, om inte så skickas felmeddelande.
if test $EUID -ne 0; then
echo "Fel: Detta skript måste köras som root"
exit 1
fi

#2 Här går skriptet igenom alla argument som skickas efter skriptet.
# @ innehåller alla namn du skickar efter skriptet.
for user in "@"; do

#Här skapas användaren i hemkataloget -m.
#Finns användaren registrerad så skickas felmeddelande och skriptet fortsätter.
if id "$user" &>/dev/null; then
echo "Användaren finns redan"
continue

else
useradd -m "$user"
echo "Skapar användare: $user"
fi

#Här skapar skriptet mappar i användarnas hemkatalog
#Här tilldelas variabeln $HOME_DIR, med användarnas hemkatalog för att slippa skriva det hela tiden.
HOME_DIR="/home/$user"

mkdir -p "$HOME_DIR/Documents" "$HOME_DIR/Downloads" "$HOME_DIR/Work"

#Här sätts rättigheter så endast ägaren kan redigera, läsa i dem samt att de är utförbara.
chmod 700 "$HOME_DIR/Documents"
chmod 700 "$HOME_DIR/Downloads"
chmod 700 "$HOME_DIR/Work"

#Här ser vi om användaren faktiskt äger sina mappar.
chown -R "$user":"$user" "$HOME_DIR/Documents" "$HOME_DIR/Downloads" "$HOME_DIR/Work"

#Här skapas en textfil i användarenas hemkatalog med ett personligt välkomstmeddelande i första raden.
echo "Välkommen $user" > "$HOME_DIR/Welcome.txt"

#I andra raden står en lista med alla användare i systemet som hämtas ifrån /etc/passwd.
echo "Här är en lista på alla användare i systemet:" >> "$HOME_DIR/Welcome.txt"
cut -d : -f1 /etc/passwd >> "$HOME_DIR/Welcome.txt"

#Här sätts även rättigheter till välkomstfilen med att läsa och skriva.
chmod 600 "$HOME_DIR/Welcome.txt"

echo "Klar med konfigurering av $user."
done

echo "Alla användare har hanterats."
