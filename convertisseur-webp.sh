#!/bin/bash
# =============================================================================
# convertisseur-webp.sh — SeedballPlanet
# Convertit les JPG et PNG en WebP avec redimensionnement automatique
# Les fichiers originaux sont supprimés après conversion réussie
# =============================================================================
# sudo apt install imagemagick webp
# --- Configuration ---
IMG_DIR="/home/sylvain/Sites/seedballplanet/img"
MAX_WIDTH=1920                 # Largeur maximale en pixels (images héros plein écran)
CONTENT_MAX_WIDTH=1200         # Largeur max pour les images de contenu (< 500 Ko originale)
QUALITY_JPG=85                 # Qualité WebP pour les JPG
QUALITY_PNG=88                 # Qualité WebP pour les PNG

# --- Couleurs pour l'affichage ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Vérification des dépendances ---
echo -e "${BLUE}=== Vérification des dépendances ===${NC}"

if ! command -v convert &> /dev/null; then
    echo -e "${RED}✗ ImageMagick n'est pas installé.${NC}"
    echo "  Installe-le avec : sudo apt install imagemagick webp"
    exit 1
fi

# Vérifier que ImageMagick supporte WebP
if ! convert -list format | grep -qi "webp"; then
    echo -e "${RED}✗ ImageMagick ne supporte pas WebP.${NC}"
    echo "  Installe le support avec : sudo apt install webp"
    exit 1
fi

echo -e "${GREEN}✓ ImageMagick avec support WebP détecté${NC}"

# Vérifier que le dossier img existe
if [ ! -d "$IMG_DIR" ]; then
    echo -e "${RED}✗ Dossier introuvable : $IMG_DIR${NC}"
    echo "  Modifie la variable IMG_DIR dans le script."
    exit 1
fi

echo -e "${GREEN}✓ Dossier images trouvé : $IMG_DIR${NC}"
echo ""

# --- Compteurs ---
COUNT=0
SKIPPED=0

# --- Traitement des images ---
echo -e "${BLUE}=== Conversion en cours ===${NC}"
echo ""

# Trouver tous les JPG et PNG (insensible à la casse)
find "$IMG_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort | while read -r FILE; do

    FILENAME=$(basename "$FILE")
    DIRPATH=$(dirname "$FILE")
    EXTENSION="${FILENAME##*.}"
    BASENAME="${FILENAME%.*}"
    WEBP_FILE="$DIRPATH/$BASENAME.webp"

    # Passer si le WebP existe déjà
    if [ -f "$WEBP_FILE" ]; then
        echo -e "  ${YELLOW}⏭ Déjà converti, ignoré :${NC} $FILENAME"
        ((SKIPPED++))
        continue
    fi

    # Obtenir les dimensions actuelles
    WIDTH=$(identify -format "%w" "$FILE" 2>/dev/null)
    ORIGINAL_SIZE=$(du -k "$FILE" | cut -f1)

    # Déterminer la largeur cible selon la taille du fichier
    # Les grosses images (> 500 Ko) = héros → max 1920px
    # Les petites images (< 500 Ko) = contenu → max 1200px
    if [ "$ORIGINAL_SIZE" -gt 500 ]; then
        TARGET_WIDTH=$MAX_WIDTH
    else
        TARGET_WIDTH=$CONTENT_MAX_WIDTH
    fi

    # Choisir la qualité selon le format source
    EXT_LOWER=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')
    if [ "$EXT_LOWER" = "png" ]; then
        QUALITY=$QUALITY_PNG
    else
        QUALITY=$QUALITY_JPG
    fi

    # Conversion avec redimensionnement si nécessaire
    if [ "$WIDTH" -gt "$TARGET_WIDTH" ]; then
        convert "$FILE" -resize "${TARGET_WIDTH}x>" -quality $QUALITY "$WEBP_FILE"
        RESIZED=" (redimensionné de ${WIDTH}px à ${TARGET_WIDTH}px)"
    else
        convert "$FILE" -quality $QUALITY "$WEBP_FILE"
        RESIZED=""
    fi

    # Calculer le gain et supprimer l'original
    if [ -f "$WEBP_FILE" ]; then
        NEW_SIZE=$(du -k "$WEBP_FILE" | cut -f1)
        GAIN=$(( (ORIGINAL_SIZE - NEW_SIZE) * 100 / ORIGINAL_SIZE ))
        rm "$FILE"
        echo -e "  ${GREEN}✓${NC} $FILENAME${RESIZED}"
        echo -e "     ${ORIGINAL_SIZE} Ko  →  ${NEW_SIZE} Ko  (${GAIN}% de gain) — original supprimé"
        ((COUNT++))
    else
        echo -e "  ${RED}✗ Échec de la conversion :${NC} $FILENAME — original conservé"
    fi

done

# --- Résumé ---
echo ""
echo -e "${BLUE}=== Résumé ===${NC}"
echo -e "  Fichiers convertis : ${GREEN}$COUNT${NC}"
echo -e "  Fichiers ignorés (déjà en WebP) : ${YELLOW}$SKIPPED${NC}"
echo ""
echo -e "${BLUE}Prochaine étape :${NC}"
echo "  Mets à jour les balises <img> et les CSS de tes pages HTML"
echo "  pour pointer vers les fichiers .webp au lieu de .jpg/.png"
echo ""
echo -e "${GREEN}Conversion terminée !${NC}"
