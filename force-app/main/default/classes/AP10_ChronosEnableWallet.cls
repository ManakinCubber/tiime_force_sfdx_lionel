public with sharing class AP10_ChronosEnableWallet {

	public class InvalidPhoneException extends Exception {}

	// Dummy classes for JSON Serialization
	
    private class Company {
		public String  legal_form      			{ get; set; }
		public String  name            			{ get; set; }
		public String  phone           			{ get; set; }
		public Boolean company_created 			{ get; set; }
		public String  siret           			{ get; set; }
		public String  street          			{ get; set; }
		public String  postal_code     			{ get; set; }
		public String  city            			{ get; set; }
        public String  main_email            	{ get; set; }
        public ApeCode  ape_code            	{ get; set; }
        public String  registration_date        { get; set; }
        public String  annual_turnover          { get; set; }
        public String  employees_range          { get; set; }
        public String  last_net_income_range	{ get; set; }
        public String  country          		{ get; set; }
		//public Decimal share_capital   { get; set; }
	}
    
	private class User {
		public String lastname  			{ get; set; }
		public String firstname 			{ get; set; }
		public String email     			{ get; set; }
		public String phone     			{ get; set; }
        public String civility     			{ get; set; }
        public String birth_date     		{ get; set; }
        public String mailing_street     	{ get; set; }
        public String mailing_postal_code	{ get; set; }
        public String mailing_city     		{ get; set; }
        public String mailing_country     	{ get; set; }
        public String nationality     		{ get; set; }
        public String birth_place     		{ get; set; }
        public String birth_country     	{ get; set; }
        public List<Company> companies		{ get; set; }
	}

	

	private class WalletParameters {
		public String lastname  			{ get; set; }
		public String firstname 			{ get; set; }
		public String email     			{ get; set; }
		public String phone     			{ get; set; }
        public String civility     			{ get; set; }
        public String birth_date     		{ get; set; }
        public String mailing_street     	{ get; set; }
        public String mailing_postal_code	{ get; set; }
        public String mailing_city     		{ get; set; }
        public String mailing_country     	{ get; set; }
        public String nationality     		{ get; set; }
        public String birth_place     		{ get; set; }
        public String birth_country     	{ get; set; }
        public List<Company> companies		{ get; set; }
		
		//public User    user    { get; set; }
		//public Company company { get; set; }
	}
    
    private class ApeCode {
        public String code 	{ get;set; }
        
        public ApeCode(String code) {
            this.code = code;
        }
    } 

	// Two identical classes because attributes
	// can be different in the future
	private class ChronosUserResponse {
		public Integer id { get; set; }
	}

	private class ChronosCompanyResponse {
		public Integer id { get; set; }
	}

	private class ChronosResponse {
		public ChronosUserResponse    user    { get; set; }
		public ChronosCompanyResponse company { get; set; }
	}

	//-------------------------------------------------------------------------

	/*
	 * @author Jérémy LAMBERT
	 * @date 04/12/2018 (dd/mm/yyyy)
	 * @description : Get the Id of the main stakeholder for the given account
	 * @params :
	 *      recordId : Account record Id
	 * @return :
	 *      stakeholder : record of the main stakeholder, throws AuraHandledException on error
	 */
	@TestVisible
	private static StakeHolder__c getMainStakeholder(String accountId) {
		List<Stakeholder__c> stakeholders = 
            [SELECT Id, Contact__c, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.MobilePhone, Contact__r.Birthdate, 
             Contact__r.MailingStreet, Contact__r.MailingPostalCode, Contact__r.MailingCity, Contact__r.MailingCountry, Contact__r.Nationality__c,
             Contact__r.BirthPlace__c, Contact__r.NativeCountry__c, Contact__r.ChronosId__c FROM Stakeholder__c WHERE (ActualBeneficiary__c = true OR Officer__c = true) AND MainStakeholder__c = true AND Company__c = :accountId];
		if(stakeholders.size() == 1) {
			return stakeholders[0];
		} else if(stakeholders.size() > 1)
			throw Utils.generateAuraHandledException('Plusieurs stakeholder principaux.');

		throw Utils.generateAuraHandledException('Aucun stakeholder trouvé.');
	}

	private static User getUser(StakeHolder__c sh, Id companyId) {
		User user = new User();
		user.firstname = sh.Contact__r.FirstName;
		user.lastname = sh.Contact__r.LastName;
		user.email = sh.Contact__r.Email;
		user.phone = formatPhoneNumber(sh.Contact__r.MobilePhone);
        user.civility = sh.Contact__r.Salutation;
		user.birth_date = formatDateForChronos(sh.Contact__r.Birthdate);
		user.mailing_street = sh.Contact__r.MailingStreet;
		user.mailing_postal_code = sh.Contact__r.MailingPostalCode;
		user.mailing_city = sh.Contact__r.MailingCity;
		user.mailing_country = sh.Contact__r.MailingCountry;
		user.nationality = sh.Contact__r.Nationality__c;
		user.birth_place = sh.Contact__r.BirthPlace__c;
		user.birth_country = sh.Contact__r.NativeCountry__c;
        user.companies = new List<Company> {getCompany(companyId)};

		return user;
	}

	/*
	 * @author Jérémy LAMBERT
	 * @date 03/05/2019 (dd/mm/yyyy)
	 * @description : Generate Company object from given Account Id
	 * @params :
	 *      recordId : Account record Id
	 * @return :
	 *      company : the company object to be serialized, throws AuraHandledException on error
	 */
	private static Company getCompany(Id companyId) {
		List<Account> accounts = [SELECT Id, LegalStatus__c, Name, MainPhoneNumber__c, CompanyCreated__c, Siret__c, BillingStreet,BillingCity,BillingPostalCode, BillingCountry, 
                                  ShareCapital__c, MainEmail__c, ApeCode__r.Name, RegistrationDate__c, AnnualTurnover__c, NumberOfEmployees__c, LastNetIncome__c 
                                  FROM Account WHERE Id = :companyId];
		if(accounts.size() == 1) {
			Account account = accounts[0];
			Company company = new Company();
			company.legal_form = account.LegalStatus__c;
			company.name = account.Name;
			company.phone = formatPhoneNumber(account.MainPhoneNumber__c);
			company.company_created = account.CompanyCreated__c;
			company.siret = account.Siret__c;
			company.street = account.BillingStreet;
			company.postal_code = account.BillingPostalCode;
			company.city = account.BillingCity;
            company.main_email = account.MainEmail__c;
            company.ape_code = new ApeCode(account.ApeCode__r.Name);
            company.registration_date = formatDateForChronos(account.RegistrationDate__c);
            company.annual_turnover = account.AnnualTurnover__c;
            company.employees_range = account.NumberOfEmployees__c;
            company.last_net_income_range = account.LastNetIncome__c;
            company.country = account.BillingCountry;
			//company.share_capital = account.ShareCapital__c;
			return company;
		}

		throw Utils.generateAuraHandledException('Aucune entreprise trouvée.');
	}

	/*
	 * @author Jérémy LAMBERT
	 * @date 03/05/2019 (dd/mm/yyyy)
	 * @description : Generate the JSON body for wallet activation.
	 * @params :
	 *      recordId : Account record Id
	 *      mainStakeholder : the main stakeholder of the Account
	 * @return :
	 *      body : the json body ready to be sent to Chronos, throws AuraHandledException on error
	 */
	private static String generateBody(Id recordId, Stakeholder__c sh) {
		WalletParameters params = new WalletParameters();

		//params.user    = getUser(mainStakeholder, Id.valueOf(recordId));
		//User user = new User();
		params.firstname = sh.Contact__r.FirstName;
		params.lastname = sh.Contact__r.LastName;
		params.email = sh.Contact__r.Email;
		params.phone = formatPhoneNumber(sh.Contact__r.MobilePhone);
        params.civility = sh.Contact__r.Salutation;
		params.birth_date = formatDateForChronos(sh.Contact__r.Birthdate);
		params.mailing_street = sh.Contact__r.MailingStreet;
		params.mailing_postal_code = sh.Contact__r.MailingPostalCode;
		params.mailing_city = sh.Contact__r.MailingCity;
		params.mailing_country = sh.Contact__r.MailingCountry;
		params.nationality = sh.Contact__r.Nationality__c;
		params.birth_place = sh.Contact__r.BirthPlace__c;
		params.birth_country = sh.Contact__r.NativeCountry__c;
        params.companies = new List<Company> {getCompany(Id.valueOf(recordId))};
		//params.company = getCompany(Id.valueOf(recordId));

		return JSON.serialize(params);
	}

	/*
	 * @author Jérémy LAMBERT
	 * @date 13/05/2019 (dd/mm/yyyy)
	 * @description : Format a phone number to the "+33" format. Returns
	 * the input number if already using good format.
	 * @params :
	 *      phone : the phone number to format
	 * @return :
	 *      formattedPhone : the formatted phone number
	 */
	@TestVisible
	private static String formatPhoneNumber(String phone) {
		if(phone != null) {
			if(phone.startsWith('0')) {
				return phone.replaceFirst('0', '+33');
			} else if(!phone.startsWith('+33')) {
				throw new InvalidPhoneException('Invalid phone number.');
			}
		}

		return phone;
	}
    
    private static String formatDateForChronos(Date dateValue) {
        String dateResult;
        if(dateValue != null) {
            dateResult = dateValue.year() + '-' + 
                (dateValue.month().format().length() == 1 ?  '0' + dateValue.month() : dateValue.month().format()) + '-' +
                (dateValue.day().format().length() == 1 ?  '0' + dateValue.day() : dateValue.day().format());
        }
        return dateResult;
    }

	/*
	 * @author Jérémy LAMBERT
	 * @date 04/12/2018 (dd/mm/yyyy)
	 * @description : HTTP Call to Chronos to enable Wallet for the main stakeholder of the given record
	 * @params :
	 *      recordId : Account record Id
	 */
	public static void enableWallet(String recordId) {

		AuthChronos__mdt auth = null;
		AuthChronos__mdt[] authList = [SELECT audience__c,client_secret__c,client_id__c,grant_type__c,
										realm__c,scope__c,url_chronos_api__c
										FROM AuthChronos__mdt
										WHERE DeveloperName=:Label.ChronosEnvironement];
		if(!authList.isEmpty()) {
			auth = authList[0];
		} else {
			throw new AuraHandledException('No Chronos Auth found.');
		}

		StakeHolder__c sh = getMainStakeholder(recordId);

		String authToken = WS02_Chronos.getToken(auth);
		String cache = 'no-cache';
		String endpoint = auth.url_chronos_api__c + '/v1/wallet/users/activation';
		String body = generateBody(recordId, sh);
		
		String response = WS02_Chronos.sendJsonChronos(authToken, cache, endpoint, body);
		ChronosResponse data = (ChronosResponse) JSON.createParser(response).readValueAs(ChronosResponse.class);

		Account account = new Account(Id = recordId);
		account.ChronosId__c = String.valueOf(data.company.id);
		update account;

		sh.Contact__r.ChronosId__c = String.valueOf(data.user.id);
		update sh.Contact__r;
	}

}