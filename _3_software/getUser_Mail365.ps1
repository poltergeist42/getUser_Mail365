<#
Infos
=====

    :Projet:             msgTracker365
    :Nom du fichier:     msgTracker365.ps1
    :Dêpot_GitHub:       https://github.com/poltergeist42/msgTracker365
    :Documentation:      https://poltergeist42.github.io/msgTracker365/
    :Auteur:            `Poltergeist42 <https://github.com/poltergeist42>`_
    :Version:            20170926-dev

####

    :Licence:            CC-BY-NC-SA
    :Liens:              https://creativecommons.org/licenses/by-nc-sa/4.0/

####

    :dev language:      Powershell
    :framework:         
    
####

Descriptif
==========

    :Projet:            Ce projet est un projet PowerShell. L'objectif est de créer un
                        Script qui interroge un domaine distant (office 365) pour en
                        extraire la liste des utilisateur possédant une adresse mail.
                        Cette export est fait sous la forme d'un fichier CSV

####

Reference Web
=============

    * https://support.office.com/fr-fr/article/Gestion-d-Office-365-et-d-Exchange-Online-avec-Windows-PowerShell-06a743bb-ceb6-49a9-a61d-db4ffdf54fa6
        # Gestion d'Office 365 et d'Exchange Online avec Windows PowerShell
        
    * https://technet.microsoft.com/library/dn975125.aspx
        # Se connecter à Office 365 PowerShell
    
    * https://technet.microsoft.com/fr-fr/library/dn568015.aspx
        # Connexion à  tous les services Office 365
        # à l'aide d'une seule fenêtre Windows PowerShell
        
    * https://technet.microsoft.com/EN-US/library/dn621038(v=exchg.160).aspx
        # Liste des commandes pour Exchange Online (module MsOnline)
    
####

Liste des modules externes
==========================

    * MsOnline

####

#>

cls
Write-Host "`t## Début du script : msgTracker365 ##"


#########################
#                       #
#     Configuration     #
#                       #
#########################

## Paramètres pour l'authentification sur Office365 / Exchange Online
$vCfgUser365 = "user@domain.dom"
    # Login utilisé pour l'authentification sur le compte Office365 / Exchange Online
    #
    # N.B : Le compte Office365 utilisé doit au minimum faire partie des groupes :
    # * Gestion de l’organisation (Organisation management)
    # * Gestion de la conformité (Compliance Management)
    #
    # Attention : "user@domain.dom" doit être remplacé par votre nom d'utilisateur
    # dans la version en production de ce script
    
$vCfgPwd365 = "P@sSwOrd"
    # Mot de passe utiliser avec le login du compte  Office365 / Exchange Online
    #
    # Attention : "P@sSwOrd" doit être remplacé par votre mot de passe
    # dans la version en production de ce script
   
   
## Paramètre pour le domaine à auditer
$vDomain = "*@domain.dom"
    # Nom de domaine à auditer  sur Office365 / Exchange Online
    #
    # Attention : "*@domain.dom" doit être remplacé par votre domaine
    # dans la version en production de ce script
        
## Paramètres pour la génération des fichiers    
$vCfgPath = ".\"
    # Chemin utilisé pour enregistrer les fichiers identifié
    #par $vCfgExpCSV et $vCfgExpBody. Si 'vCfgPath' vaut '.\', les fichiers seront crées
    # dans le répertoire d'exécution de ce script
    #
    # N.B : le chemin doit exister sur le PC avant l'exécution de se script. Ce chemin
    # peut être relatif ou absolu
    
$vCfgExpCSV = "Liste_utilisateur.csv"
    # Nom du fichier contenant le résultat de la requête. Les valeurs contenues dans se
    # fichier sont séparer par des virgules. La convention ne veut donc que l'extension
    # du fichier soit au format "CSV" (Comma-separated values). Ce fichier est généré
    # à l'endroit pointé par "$vCfgPath"
    
$vCfgEncoding = "Default"
    # Permet de définir l'encodage des fichiers et du mail. La valeur "Default",
    # récupère l'encodage du système depuis lequel est exécuter ce script.
    # Les valeurs acceptées sont :
    # "Unicode", "UTF7", "UTF8", "ASCII", "UTF32",
    # "BigEndianUnicode", "Default", "OEM"

##########################
#                        #
# Variables de requête   #
#                        #
##########################

$vPwd365 = ConvertTo-SecureString -String $vCfgPwd365 -AsPlainText -Force
$Credential365 = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $vCfgUser365, $vPwd365
    # il faut utiliser l'option : -Credential $Credential365
    # Pour pouvoir l'utiliser dans une requête

$vCSV_FQFN = "$vCfgPath\$vCfgExpCSV"
    
##########################
#                        #
# Requêtes et formatage  #
#                        #
##########################

## Connection Ã  office 365
Import-Module MsOnline
Connect-MsolService -Credential $Credential365

## Connection a Exchange Online
$exchangeSession =  New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/"`
-Credential $Credential365 -Authentication "Basic" -AllowRedirection

Import-PSSession $exchangeSession -DisableNameChecking

$v = Get-User -filter {Windowsemailaddress -like $vDomain} -Identity * | Select-Object identity, windowsemailaddress
$v | Export-Csv -Path $vCSV_FQFN  -Delimiter ";" -Encoding $vCfgEncoding

##########################
#                        #
#     Fin de tache       #
#                        #
##########################

## Fermeture de toutes les sessions distantes (les PSSession)
Get-PSSession | Remove-PSSession

Write-Host "`r`t## Fin du script : msgTracker365 ##"
