#!/bin/bash
# =============================================================================
# convertisseur-webp-pro.sh — SeedballPlanet (Optimisé)
# Utilise cwebp pour une compression supérieure et un meilleur score LCP
# =============================================================================
# Installation requise : sudo apt install webp imagemagick

IMG_DIR="/home/sylvain/Sites/seedballplanet/img"
MAX_WIDTH=1920         
CONTENT_MAX_WIDTH=1200 
QUALITY=75  # Le "sweet spot" pour le Web : 75 est souvent indiscernable de 85 mais 40% plus léger

# Couleurs
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Vérification des outils ===${NC}"
if ! command -v cwebp &> /dev/null || ! command -v identify &> /dev/null; then
    echo -e "${RED}✗ cwebp ou imagemagick manquant.${NC} Installe-les : sudo apt install webp imagemagick"
    exit 1
fi

find "$IMG_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r FILE; do
    FILENAME=$(basename "$FILE")
    DIRPATH=$(dirname "$FILE")
    BASENAME="${FILENAME%.*}"
    WEBP_FILE="$DIRPATH/$BASENAME.webp"
    
    ORIGINAL_SIZE=$(du -k "$FILE" | cut -f1)
    WIDTH=$(identify -format "%w" "$FILE")

    # Déterminer la cible (Héros vs Contenu)
    [[ "$ORIGINAL_SIZE" -gt 500 ]] && TARGET_WIDTH=$MAX_WIDTH || TARGET_WIDTH=$CONTENT_MAX_WIDTH
    
    # Calcul du redimensionnement (seulement si plus large que cible)
    RESIZE_CMD=""
    [[ "$WIDTH" -gt "$TARGET_WIDTH" ]] && RESIZE_CMD="-resize $TARGET_WIDTH 0"

    echo -n "Traitement de $FILENAME... "

    # --- L'OPTIMISATION CLÉ ICI ---
    # -m 6 : Méthode de compression la plus lente mais la plus efficace (meilleur ratio)
    # -af : Auto-filter pour lisser les gradients (ciel, peau, feuilles)
    # -sharp_yuv : Meilleure préservation des couleurs aux bords des objets (très important pour les laitues/feuilles)
    cwebp -q $QUALITY $RESIZE_CMD -m 6 -af -sharp_yuv "$FILE" -o "$WEBP_FILE" &> /dev/null

    if [ -f "$WEBP_FILE" ]; then
        NEW_SIZE=$(du -k "$WEBP_FILE" | cut -f1)
        GAIN=$(( (ORIGINAL_SIZE - NEW_SIZE) * 100 / ORIGINAL_SIZE ))
        rm "$FILE"
        echo -e "${GREEN}Fait !${NC} (${ORIGINAL_SIZE}K -> ${NEW_SIZE}K, -${GAIN}%)"
    else
        echo -e "${RED}Échec${NC}"
    fi
done

