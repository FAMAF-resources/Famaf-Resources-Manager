#! /bin/bash
#
## @file                rename_file.sh
## @author              Valentina Vispo
## @section LICENSE     Apache

folderToSearch='.github'
urlParentWorkflow='Por favor agregue el submodulo con el siguiente comando:\n\ngit submodule add git@github.com:FAMAF-resources/parentRepository.git .github\n\nLuego vuelva a correr el script.'

if [ -d "$folderToSearch" ]; then
  echo 'Archivo .github encontrado. Configurando utils para el workflow...'
  cp utilsWorkflows/labeler.yml .github/
  cp utilsWorkflows/list_auto_assign.yml .github/
  echo -e '\nConfiguracion completa.'
  exit 1
fi

echo -e "$urlParentWorkflow"
