if [ -f .env ]; then
    cp .env .env.bak
fi

if [ -f .env.prod ]; then
    cp .env.prod .env
else
    echo ".env.prod not found"
    exit 1
fi

./deploy_scripts/deploy_android_prod.sh
./deploy_scripts/deploy_ios_prod.sh

if [ -f .env.bak ]; then
    mv .env.bak .env
else
    rm -f .env
fi
