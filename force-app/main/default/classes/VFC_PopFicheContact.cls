//createdby : pascal GUILLEN
//createddate : 21/05/2018
//Description : recherche dans les champs phone et mobilephone des objets un contact puis un lead.
public class VFC_PopFicheContact {
    public PageReference loadFiche(){
        id ficheId = null;
        string phone = ApexPages.currentPage().getParameters().get('phone');
        if(string.IsNotEmpty(phone)){
            ficheId =  searchId(phone);
            if(ficheId!=null){
                return new PageReference('/'+ficheId);
            } else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'le numéro ['+phone+'] n\'est pas dans les champs Phone et MobilePhone des objets et Contact et Lead.'));
            }
        } else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Veuillez saisir un numéro de téléphone en parametre GET ?phone=xxxxxxxxx'));
        }
        return null;        
    }
    id searchId(string phone){
        Contact[] ctts=[
            SELECT id,MobilePhone,Phone 
            FROM Contact
            WHERE MobilePhone =:phone or Phone=:phone
        ];
        for(Contact ctt:ctts){
            if(ctt.MobilePhone==phone){
                return ctt.id;
            }            
        }
        for(Contact ctt:ctts){
            if(ctt.Phone==phone){
                return ctt.id;
            } 
        }
        lead[] leads =[
            SELECT id,MobilePhone,Phone 
            FROM lead
            WHERE MobilePhone =:phone or Phone=:phone
        ];
        for(lead ld:leads){
            if(ld.MobilePhone == phone){
                return ld.id;
            } 
        }
        for(lead ld:leads){
            if(ld.Phone == phone){
                return ld.id;
            } 
        }
        return null;
    }
}