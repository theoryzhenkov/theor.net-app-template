echo "Setting up environment..."
cp .envrc.example .envrc
cp .env.example .env
echo "Environment setup complete."

echo "Removing setup from justfile and self..."
sed -i '' '/^setup:$/,/^[[:space:]]*@\.\/setup\.sh/d' justfile
rm setup.sh

echo "Setup complete."