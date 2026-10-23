if [ -f .env ]; then
    cp .env .env.bak
fi

if [ -f .env.dev ]; then
    cp .env.dev .env
else
    echo ".env.dev not found"
    exit 1
fi

./deploy_scripts/deploy_android_dev.sh
./deploy_scripts/deploy_ios_dev.sh


if [ -f .env.bak ]; then
    mv .env.bak .env
else
    rm -f .env
fi
