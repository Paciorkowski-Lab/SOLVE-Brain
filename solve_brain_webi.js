<!--
/* 
*
* SOLVE-Brain Web Interface
* Version 1.0.3
*
* 1 Nov 2014
* Alex Paciorkowski
* Licensed under MIT license
*
* Allows user to upload genes via HTML5 sessionStorage
* and then link to brain-specific annotations.
*/
if (typeof(Storage)=="undefined") {
        window.alert("Your browser does not support HTML5 sessionStorage. Please upgrade your browser.");
}

var Genes = {
        index: window.sessionStorage.getItem("Genes:index"),
        $table: document.getElementById("genes-table"),
        $form: document.getElementById("genes-form"),
        $button_save: document.getElementById("genes-op-save"),
        $button_discard: document.getElementById("genes-op-discard"),

        init: function() {
                // initialize storage of gene index
                if (!Genes.index) {
                        window.sessionStorage.setItem("Genes:index", Genes.index = 1);                                                          }

                //initialize user form
                Genes.$form.reset();
                Genes.$button_discard.addEventListener("click", function(event) {
                        Genes.$form.reset();
                        Genes.$form.id_entry.value = 0;
                }, true);
                Genes.$form.addEventListener("submit", function(event) {
                	
                	//get the genes from the textbox(id="genes") as a list
                	var genes = Genes.getTextboxAsArray("genes");
                	//get the value of the id_entry to be used under the for-each loop below.
                	var idTemp = parseInt(this.id_entry.value); 
                	
                	$.each(genes, function(key, value){
                		console.log("Handling Gene: " + value);
                        var entry = {
                                id: idTemp,
                                genes: value,
                        };
                        if (entry.id == 0) { // add to the list
                                Genes.storeAdd(entry);
                                Genes.tableAdd(entry);
                        }
                        else { // edit the gene symbol
                                Genes.storeEdit(entry);
                                Genes.tableEdit(entry);
                        }
                	});
                	
                    this.reset();
                    this.id_entry.value = 0;
                    event.preventDefault();
                	
                }, true);

                // initialize table to display user data
                if (window.sessionStorage.length - 1) {
                        var genes_list = [], i, key;
                        for (i = 0; i < window.sessionStorage.length; i++) {
                                key = window.sessionStorage.key(i);
                                if (/Genes:\d+/.test(key)) {
                                        genes_list.push(JSON.parse(window.sessionStorage.getItem(key)));
                                }
                        }

                        if (genes_list.length) {
                                genes_list
                                        .sort(function(a, b) {
                                                return a.id < b.id ? -1 : (a.id > b.id ? 1 : 0);
                                        })
                                        .forEach(Genes.tableAdd);
                        }
                }
                Genes.$table.addEventListener("click", function(event) {
                        var op = event.target.getAttribute("data-op");
                        if (/edit|remove|pubmed|ucsc|lynx|allen|mgi|evs|exac/.test(op)) {
                                var entry = JSON.parse(window.sessionStorage.getItem("Genes:"+ event.target.getAttribute("data-id")));
                                if (op == "edit") {
                                       Genes.$form.genes.value = entry.genes;
                                        Genes.$form.id_entry.value = entry.id;
                                }
                                else if (op == "remove") {
                                        if (confirm('Are you sure you want to remove "'+ entry.genes +'" from your genes?')) {
                                                Genes.storeRemove(entry);
                                                Genes.tableRemove(entry);
                                        }
                                }
                                else if (op == "pubmed") {
                                        var URL = "http://www.ncbi.nlm.nih.gov/pubmed/?term="+ entry.genes +" AND brain";
                                        window.open(URL, "_blank");
                                }
                                else if (op == "ucsc") {
                                        var URL = "http://genome.ucsc.edu/cgi-bin/hgTracks?org=human&db=hg19&singleSearch=knownCanonical&position="+ entry.genes;
                                        window.open(URL, "_blank");
                                }
                                else if (op == "lynx") {
                                        var URL = "http://lynx.ci.uchicago.edu/gene/?geneid="+ entry.genes;
                                        window.open(URL, "_blank");
                                }
                                else if (op == "allen") {
                                        var URL = "http://www.brain-map.org/search/index.html?query="+ entry.genes +"&fa=false&e_sp=t&e_ag=t&e_tr=t";
                                        window.open(URL, "_blank");
                                }
                                else if (op == "mgi") {
                                        var URL = "http://www.informatics.jax.org/searchtool/Search.do?query="+ entry.genes +"&submit=Quick+Search";
                                        window.open(URL, "_blank");
                                }
                                else if (op == "evs") {
                                        var URL = "http://evs.gs.washington.edu/EVS/PopStatsServlet?searchBy=Gene+Hugo&target="+ entry.genes +"&x=0&y=0";
                                        window.open(URL, "_blank");
                                }
                                else if (op == "exac") {
                                        var URL = "http://exac.broadinstitute.org/gene/"+ entry.genes;
                                        window.open(URL, "_blank");
                                }
                         }
                                event.preventDefault();
                        
                }, true);
        },

        storeAdd: function(entry) {
                entry.id = Genes.index;
                window.sessionStorage.setItem("Genes:index", ++Genes.index);
                window.sessionStorage.setItem("Genes:"+ entry.id, JSON.stringify(entry));
        },
        storeEdit: function(entry) {
                window.sessionStorage.setItem("Genes:"+ entry.id, JSON.stringify(entry));
        },
        storeRemove: function(entry) {
                window.sessionStorage.removeItem("Genes:"+ entry.id);
        },

        tableAdd: function(entry) {
                var $tr = document.createElement("tr"), $td, key;
                for (key in entry) {
                        if (entry.hasOwnProperty(key)) {
                                $td = document.createElement("td");
                                $td.appendChild(document.createTextNode(entry[key]));
                                $tr.appendChild($td);
                        }
        }
                $td = document.createElement("td");
                $td.innerHTML = '<a data-op="edit" data-id="'+ entry.id +'">Edit <img src="../images/pencil.png" width=20px ></a> | <a data-op="remove" data-id="'+ entry.id +'">Remove <img src="../images/delete_sm.png" width=20px /></a> | <a data-op="pubmed" data-id="'+ entry.id +'">PubMed <img src="../images/PubMed.png" /></a> | <a data-op="ucsc" data-id="'+ entry.id +'">UCSC <img src="../images/UCSC.png" width=55px /></a> | <a data-op="lynx" data-id="'+ entry.id +'">Lynx <img src="../images/lynx.png" width=55px /></a> | <a data-op="allen" data-id="'+ entry.id +'">Allen <img src="../images/aibs.png" width=55px /></a> | <a data-op="mgi" data-id="'+ entry.id +'">MGI <img src="../images/mgi.png" width=45px /></a> | <a data-op="evs" data-id="'+ entry.id +'">EVS</a> | <a data-op="exac" data-id="'+ entry.id +'">ExAC</a>';
                $tr.appendChild($td);
                $tr.setAttribute("id", "entry-"+ entry.id);
                Genes.$table.appendChild($tr);
        },
        tableEdit: function(entry) {
                var $tr = document.getElementById("entry-"+ entry.id), $td, key;
                $tr.innerHTML = "";
 for (key in entry) {
                        if (entry.hasOwnProperty(key)) {
                                $td = document.createElement("td");
                                $td.appendChild(document.createTextNode(entry[key]));
                                $tr.appendChild($td);
                        }
                }
                $td = document.createElement("td");
                $td.innerHTML = '<a data-op="edit" data-id="'+ entry.id +'">Edit <img src="../images/pencil.png" width=20px /></a> | <a data-op="remove" data-id="'+ entry.id +'">Remove <img src="../images/delete_sm.png" width=20px /></a> | <a data-op="pubmed" data-id="'+ entry.id +'">PubMed <img src="../images/PubMed.png" /></a> | <a data-op="ucsc" data-id="'+ entry.id +'">UCSC <img src="../images/UCSC.png" width=55px /></a> | <a data-op="lynx" data-id="'+ entry.id +'">Lynx <img src="../images/lynx.png" width=55px /></a> | <a data-op="allen" data-id="'+ entry.id +'">Allen <img src="../images/aibs.png" width=55px /></a> | <a data-op="mgi" data-id="'+ entry.id +'">MGI <img src="../images/mgi.png" width=45px /></a> | <a data-op="evs" data-id="'+ entry.id +'">EVS</a> | <a data-op="exac" data-id="'+ entry.id +'">ExAC</a>';
                $tr.appendChild($td);
        },
        tableRemove: function(entry) {
                Genes.$table.removeChild(document.getElementById("entry-"+ entry.id));
        },
        getTextboxAsArray : function(textboxId) { //New function to get the genes entered in the textbox as an array.      
            var genes = jQuery('#'+textboxId).val().split(/\s+|,|;/);
            for (var i = 0; i < genes.length; i++) {
                if (!genes[i]) {
                    genes.splice(i, 1);
                    i--;
                }
            }
            return genes;
        }

};
Genes.init();
-->
