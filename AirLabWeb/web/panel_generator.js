function saveFile(filename, data) {
    var blob = new Blob([data], {type: 'text/csv'});
    if(window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveBlob(blob, filename);
    }
    else{
        var elem = window.document.createElement('a');
        elem.href = window.URL.createObjectURL(blob);
        elem.download = filename;        
        document.body.appendChild(elem)
        elem.click();        
        document.body.removeChild(elem);
    }
}

function generateTextFile(fileName, text){
	var a = window.document.createElement('a');
	a.href = window.URL.createObjectURL(new Blob([text], {type: 'text/csv'}));
	a.download = fileName;
		
	// Append anchor to body.
	document.body.appendChild(a);
	a.click();
	
	// Remove anchor from body
	document.body.removeChild(a);	
}

function addComponentsPanelToTemplate(panel, txtTemplate, details, templateName, version){
	
	var hardCoded = {"102":["Pd(102)", "101.905", "MCB"],
					"104":["Pd(104)", "103.904", "MCB"],
                    "105":["Pd(105)", "104.905", "MCB"],
                    "106":["Pd(106)", "105.903", "MCB"],
                    "108":["Pd(108)", "107.903", "MCB"],
                    "110":["Pd(110)", "109.905", "MCB"],
                    "113":["In(113)", "112.904", "MCB"],
                    "115":["In(115)", "114.903", "MCB"],
                    "140":["Ce(140)", "139.905", "Beads"],
                    "151":["Eu(151)", "150.919", "Beads"],
                    "153":["Eu(153)", "152.921", "Beads"],
                    "165":["Ho(165)", "164.93", "Beads"],
                    "175":["Lu(175)", "174.94", "Beads"],
                    "191":["Ir(191)", "190.96", "DNA"],
                    "193":["Ir(193)", "192.962", "DNA"],
                    "194":["Pt(194)", "193.962", "Live"],
                    "195":["Pt(195)", "194.964", "Live"]};
	
	
	var comps = txtTemplate.split('-----+++');
	
	if(comps.length == 3 && version < 3){
		var firstPart = comps[0];
		
		while(firstPart.indexOf('{panelName}') > -1){
			firstPart = firstPart.replace('{panelName}', panel.panName);
		}
		
		if(details){
			var used = [];
			var secondPart = comps[1];
		
			for(var i in details){
				var aSecond = secondPart.replace('{panelName}', panel.panName);
				var keyForMass = details[i].tagName+'-'+details[i].tagMW;
				
				var found = false;
				for(var u in used){
					if(parseInt(details[i].tagMW) == parseInt(used[u])){
						found = true;
					}
				}
				if(found == true)continue;
				else used.push(details[i].tagMW);
				
				var mass = getMassForIsotope(keyForMass);
				
				aSecond = aSecond.replace('{isotopeMass}', mass);
				
				if(details[i].clone && details[i].protein){
					var proName = details[i].protein.proName;
					proName = proName.replace(' ', '').replace('_', '').replace('/', '').replace('\\', '');
					var descrp = proName.substring(0, proName.length>7?7:proName.length);
					if(details[i].clone.cloIsPhospho == '1')descrp += '_phospho';
					descrp += '_';
					descrp += details[i].clone.cloCloneId;
					descrp += '(('+details[i].plaLabeledAntibodyId+'))';
					aSecond = aSecond.replace('{protName}', descrp);
					aSecond = aSecond.replace('{protDescription}', descrp);
				}else{
					aSecond = aSecond.replace('{protName}', 'UnknownProtein');
					aSecond = aSecond.replace('{protDescription}', 'UnknownClone');
				}
				
												
				aSecond = aSecond.replace('{atom}', details[i].tagMW);
				aSecond = aSecond.replace('{atom}', details[i].tagMW);				
				aSecond = aSecond.replace('{atomShortMass}', details[i].tagName);
				aSecond = aSecond.replace('{orderNumber}', 3000+parseInt(details[i].labBBTubeNumber));	
				firstPart += aSecond;
			}	
		}	
		firstPart += comps[2];		
		
		generateTextFile(panel.panName+'_'+templateName+'.conf', firstPart);	
	}else if(comps.length == 3 && version > 2){
		var firstPart = comps[0];
		
		if(details){
			var used = [];
			var secondPart = comps[1];
		
			for(var i in details){
				var aSecond = secondPart.replace('{panelName}', panel.panName);
				var keyForMass = details[i].tagName+'-'+details[i].tagMW;
				
				var found = false;
				for(var u in used){
					if(parseInt(details[i].tagMW) == parseInt(used[u])){
						found = true;
					}
				}
				if(found == true)continue;
				else used.push(details[i].tagMW);
								
				var mass = getMassForIsotope(keyForMass);
				aSecond = aSecond.replace('{isotopeMass}', mass);
				
				if(details[i].clone && details[i].protein){
					var proName = details[i].protein.proName;
					proName = proName.replace(' ', '').replace('_', '').replace('/', '').replace('\\', '');
					var descrp = proName.substring(0, proName.length>7?7:proName.length);
					if(details[i].clone.cloIsPhospho == '1')descrp += '_phospho';
					descrp += '_';
					descrp += details[i].clone.cloCloneId;
					descrp += '(('+details[i].plaLabeledAntibodyId+'))';					
					aSecond = aSecond.replace('{protName}', descrp);
					aSecond = aSecond.replace('{protDescription}', descrp);
				}else{
					aSecond = aSecond.replace('{protName}', 'UnknownProtein');
					aSecond = aSecond.replace('{protDescription}', 'UnknownClone');
				}
				
												
				aSecond = aSecond.replace('{atom}', details[i].tagMW);
				aSecond = aSecond.replace('{atom}', details[i].tagMW);				
				aSecond = aSecond.replace('{atom}', details[i].tagMW);	
				aSecond = aSecond.replace('{atomShortMass}', details[i].tagName);
				aSecond = aSecond.replace('{atomShortMass}', details[i].tagName);
				aSecond = aSecond.replace('{atomShortMass}', details[i].tagName);
				aSecond = aSecond.replace('{orderNumber}', 3000+parseInt(details[i].labBBTubeNumber));								
				firstPart += aSecond;
			}	
		}
		var thirdPart = comps[2];
			
		while(thirdPart.indexOf('{panelName}') > -1){
			thirdPart = thirdPart.replace('{panelName}', panel.panName);
		}
		firstPart += thirdPart;
		
		generateTextFile(panel.panName+'_'+templateName+'.tem', firstPart);
	}else{
		alert('Something went wrong and a template can\'t be generated');
	}
	
}

function generatePanelFileTemplateAndPanel(templateName, panel, details, version){
	var txt = '';
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function(){
	  if(xmlhttp.status == 200 && xmlhttp.readyState == 4){
	    txt = xmlhttp.responseText;
		addComponentsPanelToTemplate(panel, txt, details, templateName, version);
	  }
	};
	var url = "/web/"+templateName+".txt";
	console.log(url);
	xmlhttp.open("GET", url,true);
	xmlhttp.send();
	
}

function generateCSV(panel, details){
	
	var txt = 'Total Volume: 100uL,,,,,,\rTube Number,Metal Tag,Target,Antibody Clone,Stock Concentration,Final Concentration / Dilution,uL to add\r';
	for(var i in details){
		var linker = details[i];
		txt += linker.labBBTubeNumber+',';
		txt += linker.tagName+linker.tagMW+',';
		txt += linker.proName+',';
		txt += linker.cloName+',';
		txt += linker.labConcentration+',';		
		if(linker.dilutionType == '1'){
			txt += '1/'+linker.plaActualConc+',';
		}else{
			txt += linker.plaActualConc+' ug/mL,';	
		}
		txt += linker.plaPipet+'\n';
	}
	generateTextFile(panel.panName+'.csv', txt)
}

function generateCyTOF1Panel(panel, details){
	generatePanelFileTemplateAndPanel("TemplateCyTOF1", panel, details, 1);
}

function generateCyTOF2Panel(panel, details){
	generatePanelFileTemplateAndPanel("TemplateCyTOF2", panel, details, 2);
}

function generateHeliosPanel(panel, details){
	generatePanelFileTemplateAndPanel("TemplateHelios", panel, details, 3);
}