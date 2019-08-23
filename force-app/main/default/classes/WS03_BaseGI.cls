public abstract without sharing class WS03_BaseGI extends WS01_Generic {
    
    // Generic attributes and methods begin
    
    public WS03_BaseGI() {
    	queryAuth = 'SELECT CleAuth__c, Domaine__c, MethodeAppel__c, TypeAuth__c, WsEndpoint__c, StatutCodeSucces__c, AttributsGet__c FROM WSParamBaseGI__mdt';
    }
    
    public override void setRequest(Sobject authObject) {
    	WSParamBaseGI__mdt auth = (WSParamBaseGI__mdt) authObject;
	    
    	this.successCodeStatus = auth.StatutCodeSucces__c.intValue();
	    this.req.setHeader(Constants.WS_BAGI_HEADER_AUTH, auth.TypeAuth__c + ' ' + auth.CleAuth__c);
	    this.req.setEndpoint(auth.Domaine__c + auth.WsEndpoint__c + (auth.AttributsGet__c != null ? buildUrlParams(auth.AttributsGet__c) : ''));
	    this.req.setMethod(auth.MethodeAppel__c);
    
    }
    
    // La méthode va analyser les différents attributs énoncés. S'ils sont plusieurs, ils sont séparés par des ';'
    private String buildUrlParams(String attributsGet) {
    	String resultUrl = '';
    	for(String attribut : attributsGet.split(Constants.TECH_FIELD_MULTI_PICKLIST_SEPARATOR)) {
    		resultUrl += '?' + attribut + '=';
    	}
    	return resultUrl;
    }
    
    //private class WS03_Exception extends Exception {}
    
    // Generic attributes and methods end
    
    
    
    
    
    public class WsAccountFromLeadResponse {
    	public Integer code;
    	public String erreur;
    	public Integer numeroDossier;
    	public Integer idIndividu;
    	
    	public WsAccountFromLeadResponse(Integer code, String erreur, Integer numeroDossier, Integer idIndividu) {
    		this.code = code;
    		this.erreur = erreur;
    		this.numeroDossier = numeroDossier;
    		this.idIndividu = idIndividu;
    	}
    }
    
    public class WsAccountFromLeadWrapper {
    	private String leadId;
    	private String nomEntreprise;
    	private String nomLead;
    	private String emailLead;
    	private String telephoneLead;
    	private Integer idBureau;
    	private String prenomReferent;
    	private String nomReferent;
    	private String prenomContact;
    	private String nomContact;
    	private String codePostal;
    	private String ville;
    	private String adresse;
		private String typeBesoin;
		private String echeanceBesoin;
		private String statutLegal;
		private String activite;
		private String detailsActivite;
		private String utmSource;
		private String utmMedium;
		private boolean isExternalPartner;
    	
    	public WsAccountFromLeadWrapper(Lead lead, Account partenaire, Contact contactPartenaire, User referent) {
    		if(lead != null) {
    			this.leadId = lead.Id;
	    		this.nomEntreprise = checkCompanyName(lead.Company);
	    		this.nomLead = lead.Name;
	    		this.emailLead = lead.Email;
	    		this.telephoneLead = convertPhoneNumber(lead.MobilePhone);
	    		this.codePostal = lead.PostalCode;
	    		this.ville = lead.City;
	    		this.adresse = lead.Street;
				this.typeBesoin = lead.TypeOfNeed__c;
				this.echeanceBesoin = lead.Echeance_de_besoin_de_creation__c; 
				this.statutLegal = lead.LegalStatus__c; 
				this.activite = lead.Activity__c; 
				this.detailsActivite = lead.ActivityDetails__c; 
				this.utmSource = lead.UtmSource__c; 
				this.utmMedium = lead.UtmMedium__c;
				this.isExternalPartner = setIsExternalPartner(lead.Canal__c);
    		}
    		if(partenaire != null) {
    			this.idBureau = partenaire.IdBureauBaseGI__c.intValue();
    		}
    		if(contactPartenaire != null) {
	    		this.prenomContact = contactPartenaire.FirstName;
	    		this.nomContact = contactPartenaire.LastName;
    		}
    		if(referent != null) {
	    		this.prenomReferent = referent.FirstName;
	    		this.nomReferent = referent.LastName;
    		}
    	}
    	
    	public String generateJSON() {
    		return JSON.serialize(this);
    	}
    	
    	public void modifyLeadName(String newValue) {
    		this.nomLead = this.nomLead + newValue;
    	}
    	
    	private String convertPhoneNumber(String phoneNumber) {
    		return Utils.convertPhoneNumber(phoneNumber);
    	}
    	
    	private String checkCompanyName(String srcName) {
    		return (srcName != Constants.WS_BAGI_GENERIC_COMPANY_NAME ? srcName : '');
    	}
    	
    	private boolean setIsExternalPartner(String canal) {
    		return canal == Constants.LEAD_CANAL_PARTENARIATS;
    	}
    }
    
    public class WsConvertedAccountResponse {
    	public Integer code;
    	public String erreur;
    	public String url;
    	
    	public WsConvertedAccountResponse(Integer code, String erreur, String url) {
    		this.code = code;
    		this.erreur = erreur;
    		this.url = url;
    	}
    }
    
    public class WsConvertedAccountWrapper {
    	private Integer numeroDossier;
    	private String prenomContact;
    	private String nomContact;
    	private String telephoneContact;
    	private String emailContact;
    	private String adresse;
    	private String codePostal;
    	private String ville;
    	private String branding;
    	private List<WS03_BaseGI.MissionBGI> missions;
    	//private List<String> offres;
    	
    	
    	public WsConvertedAccountWrapper(Account account, Contact contact, List<Mission__c> missions) {
    		if(account != null) {
    			if((account.NumberBGI__c) != null) {
    				this.numeroDossier = account.NumberBGI__c.intValue();
    			}
    			this.adresse = account.BillingStreet;
    			this.codePostal = account.BillingPostalCode;
    			this.ville = account.BillingCity;
    			if(!account.opportunities.isEmpty()) {
    				this.branding = account.opportunities.get(0).Branding__c;
    			}
    		}
    		if(contact != null) {
    			this.prenomContact = contact.FirstName;
    			this.nomContact = contact.LastName;
    			this.telephoneContact = contact.MobilePhone;
    			this.emailContact = contact.Email;
    		}
    		this.missions = new List<WS03_BaseGI.MissionBGI>();
    		for(Mission__c m : missions) {
    			this.missions.add(new WS03_BaseGI.MissionBGI(
    				Integer.valueOf(m.MissionBgiId__c), 
    				m.Price__c, 
    				m.MissionName__c, 
    				m.OfferName__c, 
    				m.Comment__c
    			));
    		}
    	}
    	
    	public String generateJSON() {
    		return JSON.serialize(this);
    	}
    }
    
    public class WsGetOffresResponse {
    	public Integer code;
    	public String erreur;
    	public List<OffreBGI> offres;
    	
    	public WsGetOffresResponse(Integer code, String erreur, List<OffreBGI> offres) {
    		this.code = code;
    		this.erreur = erreur;
    		this.offres = offres;
    	}
    }
    
    // WS GetOffres
    public class OffreBGI {
    	private Integer id {get;set;}
    	private String designation {get;set;}
    	private List<MissionBGI> missions;
    	
    	public OffreBGI(Integer id, String designation, List<MissionBGI> missions) {
    		this.id = id;
    		this.designation = designation;
    		this.missions = missions;
    	}
    	public List<MissionBGI> getMissions() {
    		return this.missions;
    	}
    	public void setMissions(List<WS03_BaseGI.MissionBGI> missions) {
    		this.missions = missions;
    	}
    	public void addMission(WS03_BaseGI.MissionBGI mission) {
    		this.missions.add(mission);
    	}
    }
    
    public class MissionBGI {
    	private Integer id;
    	private Integer idMarque;
    	private Decimal tarif;
    	private Decimal tarifDeBase;
    	private String libelle;
    	private String periodicite;
    	private String commentaire;
    	private String offerName;
    	private Integer offerId;
    	public MissionBGI() {}
    	public MissionBGI(Integer id, Integer idMarque, Decimal tarif, String libelle, String periodicite) {
    		this.id = id;
    		this.idMarque = idMarque;
    		this.tarif = tarif;
    		this.libelle = libelle;
    	}
    	public MissionBGI(String id, Decimal tarif, Decimal tarifDeBase, String libelle, boolean periodicite, String commentaire, String offerName, String offerId) {
    		this.id = Integer.valueOf(id);
    		this.tarif = tarif;
    		this.tarifDeBase = tarifDeBase;
    		this.libelle = libelle;
    		this.periodicite = (periodicite ? 'M' : 'A');
    		this.commentaire = commentaire;
    		this.offerName = offerName;
    		this.offerId = Integer.valueOf(offerId);
    	}
    	public MissionBGI(Integer id, Decimal tarif, String libelle, String offerName, String commentaire) {
    		this.id = id;
    		this.tarif = tarif;
    		this.libelle = libelle;
    		this.offerName = offerName;
    		this.commentaire = commentaire;
    	}
    	public String getCommentaire(){return this.commentaire;}
    	public Integer getId(){return this.id;}
    	public String getLibelle(){return this.libelle;}
    	public String getOfferName(){return this.offerName;}
    	public Decimal getTarif(){return this.tarif;}
    	public Decimal getTarifDeBase(){return this.tarifDeBase;}
    	public String getPeriodicite(){return this.periodicite;}
    	public Integer getOfferId(){return this.offerId;}
    }
}