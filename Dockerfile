name: Build Frappe Suite Image

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          file: images/layered/Containerfile
          push: true
          tags: ghcr.io/SEU_USUARIO/frappe-suite:v16
          build-args: |
            FRAPPE_PATH=https://github.com/frappe/frappe
            FRAPPE_BRANCH=version-16
          secrets: |
            apps_json=./apps.json