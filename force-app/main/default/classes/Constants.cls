public class Constants {
    
    // Custom Labels Values
    public static final String SEND_EMAIL_FROM_LEAD_ADDITIONNAL_RECIPIENTS = Label.EmailRdvLead_AdditionnalRecipients;
    
    // Custom Labels Technical Values
    public static final String CUSTOM_LABEL_INNER_SEPARATOR = ';';
    
    // Template Email 
    public static final String SEND_EMAIL_FROM_LEAD_TEMPLATE_EMAIL = 'Prise_de_Rendez_vousPartner';
    public static final String EMAIL_TEMPLATE_LEGAL_RELANCE_3 = Label.EmailTemplate_JuridiqueRelance3;
    public static final String EMAIL_SUBJECT_LEGAL_RELANCE_3 = 'Tiime - création de votre société';
    public static final String EMAIL_TEMPLATE_SIGN_LINK = '<html><body style="margin: 0; padding:10px 0; background-color: #FFFFFF;" bgcolor="#FFFFFF"><table style="margin: 0 auto; background-color: #FFFFFF;" width="600" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF"><tr><td style="padding: 30px;" align="center" cellpadding="0"><img style="display: block; margin: 0; padding: 0; margin-top: 20px;" src="https://www.tiime.fr/template-mail/illus-mailing-3.jpg" alt="Illustration Tiime" width="auto" height="200"/></td></tr><tr><td style="padding: 30px;" align="left" cellpadding="0"><p style="font-family: \'Nunito\', sans-serif; font-weight: 700; font-size: 16px; line-height: 20px; color: #0098FF; margin: 0;" color="#0098FF">Bonjour !%%Contact_FirstName%%!,</p><p style="font-family: \'Nunito\', sans-serif; font-weight: 400; font-size: 14px; line-height: 20px; color: #7D839B; margin: 0; margin-top: 20px;" color="#7D839B">Suite à notre rendez-vous, vous trouverez en pièce jointe une copie de la présentation qui vous a été faite.</p><p style="font-family: \'Nunito\', sans-serif; font-weight: 400; font-size: 14px; line-height: 20px; color: #7D839B; margin: 0; margin-top: 20px;" color="#7D839B">La prochaine étape pour vous : la signature de votre contrat.</p><a style="display: block; color: #FFFFFF; background: #FF3395; width: 120px; font-family: \'Nunito\', sans-serif; font-size: 14px; text-decoration: none; text-align: center; margin: 0 auto; margin-top: 20px; padding: 8px; border-radius: 20px; font-weight: 700;" href="!%%Account_ContractSignLink__c%%!">C\'est par ici !</a><p style="font-family: \'Nunito\', sans-serif; font-weight: 400; font-size: 14px; line-height: 20px; color: #7D839B; margin: 0; margin-top: 20px;" color="#7D839B">Si vous avez des questions, n\'hésitez pas à revenir vers nous.</p><p style="font-family: \'Nunito\', sans-serif; font-weight: 700; font-size: 16px; line-height: 20px; color: #0098FF; margin: 0; margin-top: 20px;" color="#0098FF">Merci et à très bientôt,</p><p style="font-family: \'Nunito\', sans-serif; font-weight: 700; font-size: 16px; line-height: 20px; color: #0098FF; margin: 0; margin-top: 20px;" color="#0098FF">!%%FirstName%%! de la Team !%%Transfert__c_Branding__c%%!</p></td></tr><td style="background: #0098FF; padding: 30px 0px;" bgcolor="#0098FF" align="center" cellpadding="0"><p style="font-family: \'Nunito\', sans-serif; font-weight: 700; font-size: 14px; line-height: 20px; color: #FFFFFF; margin: 0;" color="#FFFFFF">!%%Account_BillingStreet%%! !%%Account_BillingPostalCode%%! !%%Account_BillingCity%%!</p><p style="font-family: \'Nunito\', sans-serif; font-weight: 700; font-size: 14px; line-height: 20px; color: #FFFFFF; margin: 0;" color="#FFFFFF">!%%Account_MainPhoneNumber__c%%!</p></td></tr></table></body></html>';
    public static final String EMAIL_TEMPLATE_PROP_ACC_RELANCE_4 = Label.EmailTemplate_PropAccompagnementRelance4;
    public static final String EMAIL_TEMPLATE_PROP_ACC_RELANCE_4_REFLEXION = Label.EmailTemplate_PropAccompagnementReflexionRelance4;
    public static final String EMAIL_TEMPLATE_PROP_ACC_RELANCE_4_WILL_SIGN = Label.EmailTemplate_PropAccompagnementWillSignRelance4;
    public static final String EMAIL_SUBJECT_SIGN_LINK = 'Votre contrat avec ';
    public static final String EMAIL_SUBJECT_SIGN_LINK_REMINDER = 'Proposition d\'accompagnement ';
    
    public static final Map<String, String> EMAIL_TEMPLATE_TO_CUSTOM_LABEL_MAP = new Map<String, String> {
    	'MailFollowUpCall3' => Label.EmailTemplate_MailFollowUpCall3,
    	'MailUnreachable' => Label.EmailTemplate_MailUnreachable,
    	'MailWrongNumber' => Label.EmailTemplate_MailWrongNumber
    };
    
    // Template SMS
    public static String EVENT_CREA_TIIME_CONFIRMATION_SMS_CONTENT = Label.SMS_CONFIRMATION_START;
    public static String EVENT_CAB_TIIME_CONFIRMATION_SMS_CONTENT = Label.SMS_CONFIRMATION_RDV_CAB;
    public static String EVENT_CAB_ONLINE_CONFIRMATION_SMS_CONTENT = Label.SMS_CONFIRMATION_RDV_CAB_ONLINE;
    public static final String SMS_LEGAL_RELANCE_2 = Label.SMS_LEGAL_Relance_2;
    public static String SMS_CAB_OPP_RELANCE_1 = Label.SMS_CAB_OPP_RELANCE_1;
    public static String SMS_CAB_OPP_RELANCE_3 = Label.SMS_CAB_OPP_RELANCE_3;
    public static String SMS_CAB_OPP_RELANCE_3_REFLEXION = Label.SMS_CAB_OPP_RELANCE_3_REFLEXION;
    public static String SMS_CAB_OPP_RELANCE_3_WILL_SIGN = Label.SMS_CAB_OPP_RELANCE_3_WILL_SIGN;
    public static String TRANSFERT_CAB_SIGN_LINK = Label.SMS_SIGN_LINK;
    
    
    public static final String SMS_TEMPLATE_TODAY = 'aujourd\'hui';
    public static final String SMS_TEMPLATE_TOMORROW = 'demain';
    
    
    // Email divers
    public static final String EMAIL_DEFAULT_FAKE_ADDRESS = 'unknow@inconnu.com';
    public static final Set<String> EMAIL_SEND_PROP_ATTACHMENT_FILE_TYPES = new Set<String> {
    	'PDF'
    };
    
    // File d'attente
    public static final String FILE_ATTENTE_OBJECT_TYPE = 'Queue';
    public static final String FILE_ATTENTE_CALL1_DEV_NAME = 'sales_tmc';
    public static final String FILE_ATTENTE_SUPPORT_TIIME = 'SupportTiime';
    
    //  Webservice
    public static final String[] INVALID_FILENAME_CHARS = new String[]{'/', '\\', '?', '%', '*', ':', '|', '"', '<', '>'};
    public static final String WS_BAGI_HEADER_AUTH = 'Authorization';
    
    public static final String WS_BAGI_ACC_CREA_FROM_LEAD_AUTH_NAME = 'AccountCreationFromLead';
    public static final String WS_BAGI_CONVERT_LEAD_AUTH_NAME = 'ConvertLeadToAccount';
    public static final String WS_BAGI_GET_OFFRES_AUTH_NAME = 'GetOffres';
    public static final String WS_COMPANEO_GET_ALL_NEW_LEADS_AUTH_NAME = 'GetAllNewLeads';
    public static final String WS_COMPANEO_GET_LEADS_TEST_AUTH_NAME = 'GetLeadsTest';
    public static final String WS_GOOGLE_API_DISTANCE_MATRIX = 'DistanceMatrix';
    public static final String WS_GOOGLE_API_PLACE_AUTOCOMPLETE = 'Place_Autocomplete';
    public static final String WS_GOOGLE_API_PLACE_DETAILS = 'Place_Details';
    
    public static final Integer WS_BAGI_PHONE_NUMBER_EXPECTED_SIZE = 10;
    public static final String PHONE_INTERNATIONAL_FRENCH_PREFIX = '+33';
    
    public static final String WS_BAGI_GENERIC_COMPANY_NAME = '[not provided]';
    
    public static final Integer WS_BAGI_ERROR_CODE_DUPLICATE = 3;
    
    public static final String WS_JINGLE_TIIME_TRIGGER_ID_TEST = 'lead_queued';
    public static final String TECH_FIELD_MULTI_PICKLIST_SEPARATOR = ';';
    
    // Field Values / Specific Values
    //Accounts
    public static final String ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT = 'Client';
    public static final String ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTNER = 'AccountantPartner';
    public static final String ACCOUNT_RECORDTYPE_NAME_PROSPECT = 'Prospect';
    public static final String ACCOUNT_RECORDTYPE_NAME_INTERNCOMP = 'Société Interne';
    public static final String ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTENARIAT = 'Partenariat';
    
    public static final String ACCOUNT_WALLET_STATUS_CGU_PENDING = 'CGUPending';
    public static final String ACCOUNT_WALLET_STATUS_KYC_PENDING = 'KYCPending';
    
    //Enquetes de Satisfaction
    public static final String ENQUETE_RECORDTYPE_DEVELOPERNAME_J10 = 'J10AfterExternalTransfer';
    public static final String ENQUETE_RECORDTYPE_DEVELOPERNAME_J5 = 'J5AfterInternalTransfer';
    public static final String ENQUETE_RECORDTYPE_DEVELOPERNAME_KBIS_J3 = 'Crea_suite_Kbis_J_3';
    public static final String ENQUETE_RECORDTYPE_DEVELOPERNAME_CONTACT = 'Prise_de_contact';
    
    public static final Map<String, String> ENQUETE_MAP_RECORDTYPE_DEVELOPERNAME_COMPONENT_TITLE = new Map<String, String> {
    	ENQUETE_RECORDTYPE_DEVELOPERNAME_J5 => 'Notes - Transfert J+5',
    	ENQUETE_RECORDTYPE_DEVELOPERNAME_J10 => 'Notes - Transfert J+10'    	
    };
    
    
    //Contacts
    public static final String CONTACT_RECORDTYPE_DEVELOPERNAME_CLIENT = 'Customer';
    public static final String CONTACT_RECORDTYPE_DEVELOPERNAME_PARTNER = 'AccountantPartner';
    
    // Leads
    public static final String LEAD_OBJECT_API_NAME = 'Lead';
    public static final String LEAD_OBJECT_PREFIX_ID = '00Q';
    
    public static final String LEAD_RECORDTYPE_DEVELOPERNAME_LEAD_CLIENT = 'LeadClient';
    public static final String LEAD_RECORDTYPE_DEVELOPERNAME_PARTENARIAT = 'Partenariat';
    
    public static final String LEAD_CANAL_PARTENARIATS = 'partenariats';
    public static final String LEAD_CANAL_SEO = 'seo';
    
    public static final String LEAD_STATUS_CALL1 = 'Call 1';
    public static final String LEAD_STATUS_CALL2 = 'Call 2';
    public static final String LEAD_STATUS_CALL3 = 'Call 3';
    public static final String LEAD_STATUS_CALL4 = 'Call 4';
    public static final String LEAD_STATUS_CALL5 = 'Call 5';
    public static final String LEAD_STATUS_CALL6 = 'Call 6';
    public static final String LEAD_STATUS_CALL7 = 'Call 7';
    public static final String LEAD_STATUS_PERDU = 'Perdu';
    public static final String LEAD_STATUS_EC_A_TROUVER = 'EC à Trouver';
    public static final String LEAD_STATUS_CONVERTI = 'Converti';
    public static final String LEAD_STATUS_TRANSFERT = 'Transfert';
    
    public static final Map<String, String> LEAD_MAP_NEXT_STATUS = new Map<String, String> {
	   LEAD_STATUS_CALL1 => LEAD_STATUS_CALL2,
	   LEAD_STATUS_CALL2 => LEAD_STATUS_CALL3,
	   LEAD_STATUS_CALL3 => LEAD_STATUS_CALL4,
	   LEAD_STATUS_CALL4 => LEAD_STATUS_CALL5,
	   LEAD_STATUS_CALL5 => LEAD_STATUS_CALL6,
	   LEAD_STATUS_CALL6 => LEAD_STATUS_CALL7,
	   LEAD_STATUS_CALL7 => LEAD_STATUS_PERDU,
	   LEAD_STATUS_PERDU => LEAD_STATUS_EC_A_TROUVER,
	   LEAD_STATUS_EC_A_TROUVER => LEAD_STATUS_CONVERTI,
	   LEAD_STATUS_CONVERTI => LEAD_STATUS_TRANSFERT 
    };
    
    public static final String LEAD_BRANDING_TIIME = 'Tiime';
    public static final String LEAD_BRANDING_NOVAA = 'Novaa';
    public static final String LEAD_BRANDING_INCITYZ = 'Incityz';
    public static final String LEAD_BRANDING_CONDILLAC = 'Condillac';
    public static final String LEAD_BRANDING_GONEO = 'Goneo';
    public static final String LEAD_BRANDING_PEPIT = 'Pepit';
    public static final String LEAD_BRANDING_LEC = 'L-Expert-Comptable.com';
    public static final String LEAD_BRANDING_LEC_LILLE = 'L-Expert-Comptable Lille';
    
    public static final Map<String, Set<Integer>> BRANDING_TO_OFFRES_MAP = new Map<String, Set<Integer>> {
    	LEAD_BRANDING_NOVAA => new Set<Integer> {1, 2, 3, 4, 5, 6},
    	LEAD_BRANDING_INCITYZ => new Set<Integer> {3, 4, 6, 9, 10, 11},
    	LEAD_BRANDING_LEC => new Set<Integer> {3, 4, 5, 6, 7, 8},
    	LEAD_BRANDING_CONDILLAC => new Set<Integer> {3, 4, 6, 9, 10, 11}
    };
    
    public static final Map<String, String> BRANDING_PDF_OFFER_NAME_MAP = New Map<String, String> {
    	LEAD_BRANDING_LEC => 'Présentation offre l-expert-comptable.com',
    	LEAD_BRANDING_NOVAA => 'Présentation Offre Novaa'
    };
    
    public static final String LEAD_UTM_SOURCE_PARTENAIRE = 'Partenaire';
      
    public static final String LEAD_COUNTRY_DEFAULT = 'France';
    
    public static final String LEAD_SUIVI_TRANSFERT_INJOIGNABLE = 'Injoignable';
	
	public static final String LEAD_TYPE_RENVOI_EN_COURS = 'Lead en cours';
	public static final String LEAD_TYPE_RENVOI_ERREUR_CASTING = 'Erreur de casting';
    public static final String LEAD_TYPE_RENVOI_HORS_CIBLE = 'Lead hors cible';
    
    public static final String LEAD_WEBSITE_ORIGIN_COMPANEO = 'Companeo';
    
    
    public static final String SEND_EMAIL_FROM_LEAD_SUBJECT = 'Rendez-vous avec ';
    
    public static final String LEAD_RDV_TYPE_PHYSIQUE = 'physique';
    public static final String LEAD_RDV_TYPE_TELEPHONIQUE = 'Téléphonique';
    
    public static final String LEAD_RDV_LIEU_BUREAU = 'au bureau';
    public static final String LEAD_RDV_LIEU_CLIENT = 'chez le client';
    
    public static final Double LEAD_MAX_DISTANCE_FROM_PARTNER = 100; //Km
    public static final List<String> LEAD_ACCOUNT_RECORDTYPES_FOR_APPOINTMENT = new List<String>{
        'AccountantPartner', 'InternalCompany'
    };
    
    // Opportunities
    public static final String OPP_OBJECT_API_NAME = 'Opportunity';
    public static final String OPP_OBJECT_PREFIX_ID = '006';

	public static final String OPP_STEP_RELANCE_1 = 'Relance';
	public static final String OPP_STEP_RELANCE_2 = 'Relance 2';
	public static final String OPP_STEP_RELANCE_3 = 'Relance 3';
	public static final String OPP_STEP_RELANCE_4 = 'Relance 4';
	public static final String OPP_STEP_RELANCE_5 = 'Relance 5';
    public static final String OPP_STAGENAME_PROP_SENT = 'Proposition envoyée';
    public static final String OPP_STAGENAME_NURTURING = 'Nurterring';
    public static final String OPP_STAGENAME_CONTRACT_SIGNED = 'Contrat signé';
    public static final String OPP_STAGENAME_LOST = 'Opportunité perdue';
    
    public static final Set<String> OPP_STAGENAME_CLOSED_SET = new Set<String> {
    	OPP_STAGENAME_CONTRACT_SIGNED,
    	OPP_STAGENAME_LOST
    };
    
    public static final String OPP_LOSS_REASON_AMONT = 'Projet trop en amont';
    public static final String OPP_LOSS_REASON_CONCURRENCE = 'Concurrence';
    
    
    
    // Profiles
    public static final String PROFILE_NAME_ACCOUNT_EXECUTIVE = 'AE';
    
    //Stakeholders
    public static final String STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP = 'Personne_Physique';
    public static final String STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PM = 'Personne_Morale';
    
    
    // Tasks
    public static final String TASK_RECORDTYPE_DEVELOPERNAME_TRANSFERT = 'TacheTransfert';
    public static final String TASK_RECORDTYPE_DEVELOPERNAME_CABINET = 'TacheCabinets';
    public static final String TASK_RECORDTYPE_DEVELOPERNAME_CAB_AUTO = 'TacheCabinetsAutoMail';
    public static final String TASK_RECORDTYPE_DEVELOPERNAME_CAB_LAST_CALL = 'TacheCabinetsLastCall';
    
    public static final String TASK_SUBJECT_LEGAL_REMINDER_1 = 'Relance 1 - ';
    public static final String TASK_SUBJECT_LEGAL_REMINDER_2 = 'Relance 2 - ';
    public static final String TASK_SUBJECT_LEGAL_REMINDER_3 = 'Relance 3 - ';
    public static final String TASK_SUBJECT_LEGAL_REMINDER_4 = 'Relance 4 - ';
    public static final String TASK_SUBJECT_LEGAL_REMINDER_5 = 'Relance 5 - ';
    
    public static final String TASK_SUBJECT_CAB_REMINDER_1 = 'RDV échoué - Relance 1 - Appel';
    public static final String TASK_SUBJECT_CAB_REMINDER_2 = 'RDV échoué - Relance 2 - Appel';
    public static final String TASK_SUBJECT_CAB_REMINDER_3 = 'RDV échoué - Relance 3 - Appel';
    public static final String TASK_SUBJECT_AVEC = ' avec ';
    
    public static final String TASK_SUBJECT_CAB_OPP_REMINDER_1 = 'Relance 1 - Appel (+SMS)';
    public static final String TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_2 = 'Relance 2 - Appel';
    public static final String TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_3 = 'Relance 3 - Appel (+SMS)';
    public static final String TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_4 = 'Relance 4 - E-mail automatique';
    public static final String TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_5 = 'Dernière Relance avant Nurturing - Appel';
    public static final String TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_2 = 'En Réflexion Relance 2 - Appel';
    public static final String TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_3 = 'En Réflexion Relance 3 - Appel (+SMS)';
    public static final String TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_4 = 'En Réflexion Relance 4 - E-mail automatique';
    public static final String TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_5 = 'En Réflexion : Dernière Relance avant Nurturing - Appel';
    public static final String TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_2 = 'Engagement Signature Relance 2 - Appel';
    public static final String TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_3 = 'Engagement Signature Relance 3 - Appel (+SMS)';
    public static final String TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_4 = 'Engagement Signature Relance 4 - E-mail automatique';
    public static final String TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_5 = 'Engagement Signature : Dernière Relance avant Nurturing - Appel';
    
    public static final String TASK_EVENT_POSTPONEMENT_PREFIX = 'Rappel souhaité suite ';
    public static final Integer TASK_EVENT_DURATION_MINUTES = 15;
    
    
    public static final String TASK_RELANCE_1 = '1';
    public static final String TASK_RELANCE_2 = '2';
    public static final String TASK_RELANCE_3 = '3';
    public static final String TASK_RELANCE_4 = '4';
    public static final String TASK_RELANCE_LAST_CALL = 'Last Call';
    
    public static final String TASK_STATUS_OPEN = 'Ouvert';
    public static final String TASK_STATUS_CLOSED = 'Terminé';
    
    public static final String TASK_ISSUE_RELANCE_NO_RESPONSE = 'Pas de réponse';
    public static final String TASK_ISSUE_RELANCE_REFLEXION = 'En réflexion';
    public static final String TASK_ISSUE_RELANCE_WILL_SIGN = 'Engagement Signature';
    public static final String TASK_ISSUE_RELANCE_NURTURING = 'Nurturing';
    public static final String TASK_ISSUE_RELANCE_POSTPONED = 'Relance reportée';
    public static final String TASK_ISSUE_RELANCE_LOST_AMONT = 'Perte Trop en amont';
    public static final String TASK_ISSUE_RELANCE_LOST_CONCURRENCE = 'Perte Concurrence';
    public static final String TASK_ISSUE_RELANCE_PROP_SENT = 'Proposition envoyée';
    
    public static final Set<String> TASK_ISSUE_RELANCE_LOST_VALUE_SET = new Set<String> {
    	TASK_ISSUE_RELANCE_LOST_AMONT,
    	TASK_ISSUE_RELANCE_LOST_CONCURRENCE
    };
    
    public static Set<String> TASK_ISSUES_VALUES_NOT_APPLICABLE_ON_CAB_TASK = new Set<String> {
    	TASK_ISSUE_RELANCE_NURTURING,
    	TASK_ISSUE_RELANCE_PROP_SENT
    };
    
    public static final Map<String, String> TASK_ISSUE_TO_OPP_LOSS_REASON_MAP = new Map<String, String> {
    	TASK_ISSUE_RELANCE_LOST_AMONT => OPP_LOSS_REASON_AMONT,
    	TASK_ISSUE_RELANCE_LOST_CONCURRENCE => OPP_LOSS_REASON_CONCURRENCE
    };
    
    public static final Set<String> TASK_ISSUE_RELANCE_NEW_TRY_FAIL = new Set<String> {
    	TASK_ISSUE_RELANCE_NO_RESPONSE,
    	TASK_ISSUE_RELANCE_REFLEXION,
    	TASK_ISSUE_RELANCE_WILL_SIGN
    };
    
    public static final Map<String, String> TASK_LEGAL_SUBJECT_ORDER = new Map<String, String> {
    	TASK_SUBJECT_LEGAL_REMINDER_1 => TASK_SUBJECT_LEGAL_REMINDER_2,
    	TASK_SUBJECT_LEGAL_REMINDER_2 => TASK_SUBJECT_LEGAL_REMINDER_3,
    	TASK_SUBJECT_LEGAL_REMINDER_3 => TASK_SUBJECT_LEGAL_REMINDER_4,
    	TASK_SUBJECT_LEGAL_REMINDER_4 => TASK_SUBJECT_LEGAL_REMINDER_5
    };
    
    public static final Map<String, Integer> TASK_LEGAL_NB_DAYS_FOR_NEXT_CALL = new Map<String, Integer> {
    	TASK_SUBJECT_LEGAL_REMINDER_1 => 1,
    	TASK_SUBJECT_LEGAL_REMINDER_2 => 1,
    	TASK_SUBJECT_LEGAL_REMINDER_3 => 7,
    	TASK_SUBJECT_LEGAL_REMINDER_4 => 7
    };
    
    public static final Map<String, String> TASK_CAB_ORDER = new Map<String, String> {
    	TASK_SUBJECT_CAB_REMINDER_1 => TASK_SUBJECT_CAB_REMINDER_2,
    	TASK_SUBJECT_CAB_REMINDER_2 => TASK_SUBJECT_CAB_REMINDER_3
    };
    
    public static final Map<String, Integer> TASK_CAB_NB_DAYS_FOR_NEXT_CALL = new Map<String, Integer> {
    	TASK_SUBJECT_CAB_REMINDER_1 => 1,
    	TASK_SUBJECT_CAB_REMINDER_2 => 1
    };
    
    public static final Map<String, String> TASK_CAB_RELANCE = new Map<String, String> {
    	TASK_SUBJECT_CAB_REMINDER_1 => TASK_RELANCE_2,
    	TASK_SUBJECT_CAB_REMINDER_2 => TASK_RELANCE_3
    };
    
    public static final Map<String, String> TASK_CAB_OPP_RELANCE = new Map<String, String> {
    	TASK_RELANCE_1 => TASK_RELANCE_2,
    	TASK_RELANCE_2 => TASK_RELANCE_3,
    	TASK_RELANCE_3 => TASK_RELANCE_4,
    	TASK_RELANCE_4 => TASK_RELANCE_LAST_CALL
    };
    
    public static final Map<String, String> TASK_CAB_OPP_RELANCE_SUBJECT_NO_RESP = new Map<String, String> {
    	TASK_RELANCE_1 => TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_2,
    	TASK_RELANCE_2 => TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_3,
    	TASK_RELANCE_3 => TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_4,
    	TASK_RELANCE_4 => TASK_SUBJECT_CAB_OPP_NO_RESP_REMINDER_5
    };
    
    public static final Map<String, String> TASK_CAB_OPP_RELANCE_SUBJECT_REFLEXION = new Map<String, String> {
    	TASK_RELANCE_1 => TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_2,
    	TASK_RELANCE_2 => TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_3,
    	TASK_RELANCE_3 => TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_4,
    	TASK_RELANCE_4 => TASK_SUBJECT_CAB_OPP_REFLEXION_REMINDER_5
    };
    
    public static final Map<String, String> TASK_CAB_OPP_RELANCE_SUBJECT_WILL_SIGN = new Map<String, String> {
    	TASK_RELANCE_1 => TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_2,
    	TASK_RELANCE_2 => TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_3,
    	TASK_RELANCE_3 => TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_4,
    	TASK_RELANCE_4 => TASK_SUBJECT_CAB_OPP_WILL_SIGN_REMINDER_5
    };
    
    public static final Map<String, Map<String, String>> TASK_CAB_OPP_ISSUE_SUBJECT_MAPS = new Map<String, Map<String, String>> {
    	TASK_ISSUE_RELANCE_NO_RESPONSE => TASK_CAB_OPP_RELANCE_SUBJECT_NO_RESP,
    	TASK_ISSUE_RELANCE_REFLEXION => TASK_CAB_OPP_RELANCE_SUBJECT_REFLEXION, 
    	TASK_ISSUE_RELANCE_WILL_SIGN => TASK_CAB_OPP_RELANCE_SUBJECT_WILL_SIGN
    };
    
    public static final Map<String, Integer> TASK_CAB_OPP_NB_DAYS_FOR_NEXT_CALL_NO_RESP = new Map<String, Integer> {
    	TASK_RELANCE_1 => 2,
    	TASK_RELANCE_2 => 5,
    	TASK_RELANCE_3 => 7,
    	TASK_RELANCE_4 => 7
    };
    
    public static final Map<String, Integer> TASK_CAB_OPP_NB_DAYS_FOR_NEXT_CALL_REFLEXION = new Map<String, Integer> {
    	TASK_RELANCE_1 => 7,
    	TASK_RELANCE_2 => 7,
    	TASK_RELANCE_3 => 7,
    	TASK_RELANCE_4 => 7
    };
    
    public static final Map<String, Integer> TASK_CAB_OPP_NB_DAYS_FOR_NEXT_CALL_WILL_SIGN = new Map<String, Integer> {
    	TASK_RELANCE_1 => 7,
    	TASK_RELANCE_2 => 7,
    	TASK_RELANCE_3 => 7,
    	TASK_RELANCE_4 => 7
    };
    
    public static final Map<String, Map<String, Integer>> TASK_CAB_OPP_ISSUE_NB_DAYS_FOR_NEXT_CALL_MAPS = new Map<String, Map<String, Integer>> {
    	TASK_ISSUE_RELANCE_NO_RESPONSE => TASK_CAB_OPP_NB_DAYS_FOR_NEXT_CALL_NO_RESP,
    	TASK_ISSUE_RELANCE_REFLEXION => TASK_CAB_OPP_NB_DAYS_FOR_NEXT_CALL_REFLEXION, 
    	TASK_ISSUE_RELANCE_WILL_SIGN => TASK_CAB_OPP_NB_DAYS_FOR_NEXT_CALL_WILL_SIGN
    };
    
    public static final Map<String, String> TASK_CAB_OPP_RELANCE_RECORDTYPE = new Map<String, String> {
    	TASK_RELANCE_1 => TASK_RECORDTYPE_DEVELOPERNAME_CABINET,
    	TASK_RELANCE_2 => TASK_RECORDTYPE_DEVELOPERNAME_CABINET,
    	TASK_RELANCE_3 => TASK_RECORDTYPE_DEVELOPERNAME_CAB_AUTO,
    	TASK_RELANCE_4 => TASK_RECORDTYPE_DEVELOPERNAME_CAB_LAST_CALL
    };
    
    // SF-503
    public static final Map<String, String> OLD_TASK_RELANCE_VALUE_NEW_OPP_STEP_MAP = new Map<String, String> {
    	TASK_RELANCE_1 => OPP_STEP_RELANCE_2,
    	TASK_RELANCE_2 => OPP_STEP_RELANCE_3,
    	TASK_RELANCE_3 => OPP_STEP_RELANCE_4,
    	TASK_RELANCE_4 => OPP_STEP_RELANCE_5
    };
    
    // Transferts
    public static final String TRANSFERT_OBJECT_API_NAME = 'Transfert__c';
    public static final String TRANSFERT_OBJECT_PREFIX_ID = 'a1p';
    
    public static final String TRANSFERT_ETAPE_RDV_ECHOUE = 'Rdv Echoué';
    public static final String TRANSFERT_ETAPE_PROP_ENVOYEE = 'Proposition Envoyée';
    
    // PAD
    public static final String BYPASS_AP16 = 'AP16_ManageRecordTypeFromHeroku';
    
    
    // Projets de creation (Start__c)
    public static final String START_OBJECT_PREFIX_ID = 'a0I';
    public static final String START_OBJECT_API_NAME = 'Start__c';
    
    public static final String START_STATUS_KBIS = 'Kbis reçu';
    
    //SMS du standard SDR
    public static final String PHONE_STANDARD_SDR = Label.PHONE_STANDARD_SDR;
}