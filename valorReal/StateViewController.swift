//
//  EstadoViewController.swift
//  valorReal
//
//  Created by user139409 on 5/3/18.
//  Copyright © 2018 Usuário Convidado. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class StateViewController: UIViewController {
    
    var stateManager = StateManager.shared
    
    let config = Configuration.shared
    var calc = Calcular.shared

    @IBOutlet weak var tfCotation: UITextField!
    @IBOutlet weak var tf_iof: UITextField!
    @IBOutlet weak var tvStates: UITableView!
    @IBOutlet weak var btnAddState: UIButton!
    
    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        loadValues()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //aqui grava
        if tf_iof.text?.isEmpty == false {
            config.txIOF = calc.verificaSinal(tf_iof.text!)            
        }
        
        if tfCotation.text?.isEmpty == false {
            config.cotDolar = calc.verificaSinal(tfCotation.text!)
        }
    }
    
    func loadValues() {
        //aqui apresenta
        tfCotation.text = config.cotDolar
        tf_iof.text = config.txIOF
    }
    
    func loadStates() {
        stateManager.loadStates(with: context)
        tvStates.reloadData()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //aqui grava
        if tf_iof.text?.isEmpty == false {
            config.txIOF = calc.verificaSinal(tf_iof.text!)
            
        }
        
        if tfCotation.text?.isEmpty == false {
            config.cotDolar = calc.verificaSinal(tfCotation.text!)
        }
        
        tf_iof.resignFirstResponder()
        tfCotation.resignFirstResponder()
    }
    
    @IBAction func btAddEditState(_ sender: Any) {
        showAlert(with: nil)
        
    }
    
    func showAlert(with state: State?) {
        let title = state == nil ? "Adicionar Estado" : "Editar Estado"
        let btTitle = state == nil ? "Adicionar" : "Alterar"
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome do Estado"
            if let estUSA = state?.name {
                textField.text = estUSA
            }
        }
        
        alert.addTextField { (txtTaxa) in
            txtTaxa.placeholder = "Imposto"
            txtTaxa.keyboardType = UIKeyboardType.decimalPad
            
            if let estTaxa = state?.tax {
                txtTaxa.text = self.calc.getFormattedValue(of: estTaxa, withCurrency: "")
            }
        }
        
        alert.addAction(UIAlertAction(title: btTitle, style: .default, handler: {(action) in
            
            var erros:String = ""
            
            if(alert.textFields?[0].text?.isEmpty == true){
                erros.append("Nome do estado requerido\n")
            }
            
            if(alert.textFields?[1].text?.isEmpty == true){
                erros.append("Imposto do estado requerido\n")
            }
            
            if erros.description != "" && erros.description.isEmpty == false {
                self.showMsg(ptitle: "Validacao",pMsg: erros.description)
            }
            else
            {
                do
                {
                    let state = state ?? State(context: self.context)
                    let vlTax: String = self.calc.verificaSinal((alert.textFields?[1].text)!)
                    
                    state.tax = self.calc.convertDouble(vlTax)
                    state.name = alert.textFields?[0].text
                    
                    try self.context.save()
                    self.loadStates()
                }
                catch {
                    print()
                }
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showMsg(ptitle: String, pMsg: String) {
        
        let alertController = UIAlertController(title: ptitle, message: pMsg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tf_iof.resignFirstResponder()
        tfCotation.resignFirstResponder()
        tvStates.deselectRow(at: indexPath, animated: false)
        
        let state = stateManager.states[indexPath.row]
        showAlert(with: state)
        
    }
    
}

extension StateViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = stateManager.states.count
        
        tvStates.backgroundView = count == 0 ? label : nil
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tvStates.dequeueReusableCell(withIdentifier: "statecell", for: indexPath) as! StateTableViewCell
        let state = stateManager.states[indexPath.row]
        cell.prepare(witch: state)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stateManager.deleteState(index: indexPath.row, with: context)
            //estadoManager.estados.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
