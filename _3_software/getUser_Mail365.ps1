<#
Infos
=====

    :Projet:             msgTracker365
    :Nom du fichier:     msgTracker365.ps1
    :D�pot_GitHub:       https://github.com/poltergeist42/msgTracker365
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

    :Projet:            Ce projet est un projet PowerShell. L'objectif est de cr�er un
                        Script qui interroge un domaine distant (office 365) pour en
                        extraire la liste des utilisateur poss�dant une adresse mail.
                        Cette export est fait sous la forme d'un fichier CSV

####

Reference Web
=============

    * https://support.office.com/fr-fr/article/Gestion-d-Office-365-et-d-Exchange-Online-avec-Windows-PowerShell-06a743bb-ceb6-49a9-a61d-db4ffdf54fa6
        # Gestion d'Office 365 et d'Exchange Online avec Windows PowerShell
        
    * https://technet.microsoft.com/library/dn975125.aspx
        # Se connecter � Office 365 PowerShell
    
    * https://technet.microsoft.com/fr-fr/library/dn568015.aspx
        # Connexion �  tous les services Office 365
        # � l'aide d'une seule fen�tre Windows PowerShell
        
    * https://technet.microsoft.com/EN-US/library/dn621038(v=exchg.160).aspx
        # Liste des commandes pour Exchange Online (module MsOnline)
    
####

Liste des modules externes
==========================

    * MsOnline

####

#>

cls
Write-Host "`t## D�but du script : msgTracker365 ##"


#########################
#                       #
#     Configuration     #
#                       #
#########################

## Param�tres pour l'authentification sur Office365 / Exchange Online
$vCfgUser365 = "user@domain.dom"
    # Login utilis� pour l'authentification sur le compte Office365 / Exchange Online
    #
    # N.B : Le compte Office365 utilis� doit au minimum faire partie des groupes :
    # * Gestion de l�organisation (Organisation management)
    # * Gestion de la conformit� (Compliance Management)
    #
    # Attention : "user@domain.dom" doit �tre remplac� par votre nom d'utilisateur
    # dans la version en production de ce script
    
$vCfgPwd365 = "P@sSwOrd"
    # Mot de passe utiliser avec le login du compte  Office365 / Exchange Online
    #
    # Attention : "P@sSwOrd" doit �tre remplac� par votre mot de passe
    # dans la version en production de ce script
   
   
## Param�tre pour le domaine � auditer
$vDomain = "*@domain.dom"
    # Nom de domaine � auditer  sur Office365 / Exchange Online
    #
    # Attention : "*@domain.dom" doit �tre remplac� par votre domaine
    # dans la version en production de ce script
        
## Param�tres pour la g�n�ration des fichiers    
$vCfgPath = ".\"
    # Chemin utilis� pour enregistrer les fichiers identifi�
    #par $vCfgExpCSV et $vCfgExpBody. Si 'vCfgPath' vaut '.\', les fichiers seront cr�es
    # dans le r�pertoire d'ex�cution de ce script
    #
    # N.B : le chemin doit exister sur le PC avant l'ex�cution de se script. Ce chemin
    # peut �tre relatif ou absolu
    
$vCfgExpCSV = "Liste_utilisateur.csv"
    # Nom du fichier contenant le r�sultat de la requ�te. Les valeurs contenues dans se
    # fichier sont s�parer par des virgules. La convention ne veut donc que l'extension
    # du fichier soit au format "CSV" (Comma-separated values). Ce fichier est g�n�r�
    # � l'endroit point� par "$vCfgPath"
    
$vCfgEncoding = "Default"
    # Permet de d�finir l'encodage des fichiers et du mail. La valeur "Default",
    # r�cup�re l'encodage du syst�me depuis lequel est ex�cuter ce script.
    # Les valeurs accept�es sont :
    # "Unicode", "UTF7", "UTF8", "ASCII", "UTF32",
    # "BigEndianUnicode", "Default", "OEM"

##########################
#                        #
# Variables de requ�te   #
#                        #
##########################

$vPwd365 = ConvertTo-SecureString -String $vCfgPwd365 -AsPlainText -Force
$Credential365 = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $vCfgUser365, $vPwd365
    # il faut utiliser l'option : -Credential $Credential365
    # Pour pouvoir l'utiliser dans une requ�te

$vCSV_FQFN = "$vCfgPath\$vCfgExpCSV"
    
##########################
#                        #
# Requ�tes et formatage  #
#                        #
##########################

## Connection �  office 365
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
