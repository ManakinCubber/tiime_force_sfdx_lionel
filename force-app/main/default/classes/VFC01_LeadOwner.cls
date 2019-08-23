/*******************************************************
Nom ......... : VFC01_LeadOwner.cls
Description	  : Set the lead owner of selected or current
				lead to the current user

Auteur ...... : LAMBERT Jérémy & JEAN-BAPTISTE Félix
********************************************************/
public class VFC01_LeadOwner {

	private ApexPages.StandardSetController controllerMultiple;
	private ApexPages.StandardController controllerSimple;

	public VFC01_LeadOwner(ApexPages.StandardSetController controller) {
		controllerMultiple = controller;
	}

	public VFC01_LeadOwner(ApexPages.StandardController controller) {
		controllerSimple = controller;
	}

	private void showError(String message) {
		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
	}

	private boolean assign() {
        System.debug('****************** ASSIGN *****************');
		try {
			Lead lead = (Lead) controllerSimple.getRecord();
			lead.OwnerId = UserInfo.getUserId();
			update lead;
		} catch(DmlException e) {
			showError('Une erreur est survenue lors de la mise à jour de l\'enregistrement : ' + e.getMessage());
			return false;
		}
		return true;
	}

	private boolean massAssign() {
        System.debug('****************** MASS ASSIGN *****************');
		try {
			System.debug('id infoUser pendant2: '+ UserInfo.getUserId());
			Lead[] leads = (Lead[])controllerMultiple.getSelected();
            System.debug('nb leads trouvé ? : '+leads.size());
            if(leads.size()==0) return false;
			for(Lead l : leads){
				System.debug('id infoUser pendant3: '+ UserInfo.getUserId());
				l.OwnerId = UserInfo.getUserId();
			}
			update leads;
		} catch(DmlException e) {
			showError('Une erreur est survenue lors de la mise à jour de l\'enregistrement : ' + e.getMessage());
			return false;
		}
		return true;
	}

	public PageReference assignAndRedirect() {
		System.debug('id infoUser pendant1: '+ UserInfo.getUserId());
		if(controllerSimple != null && assign()) {
			PageReference pageRef = controllerSimple.view();
			pageRef.setRedirect(true);
			return pageRef;
		} else if(controllerMultiple != null && massAssign()) {
			PageReference pageRef = new PageReference('/lightning/o/Lead/list');
			pageRef.setRedirect(true);
			return pageRef;
		}
		showError('Aucun enregistrement sélectionné.');
		PageReference pageRef = new PageReference('/lightning/o/Lead/list');
		pageRef.setRedirect(true);
		return pageRef;
	}

}