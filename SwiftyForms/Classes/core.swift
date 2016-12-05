
import Foundation
import UIKit


public protocol Field: class {
  associatedtype ValueType
  associatedtype Widget
  associatedtype ValidatorType
  var data:ValueType? { get set }
  var placeholder:ValueType?{ get set }
  
  var widget:Widget{ get }
  
  var errors:[FormError] { get set}
  var name:String{ get }
  var label:String? { get set }
  var description:String? { get set }
  
  
  var isRequired:Bool { get }
  var validators:[ValidatorType] { get }
  //  func validate() -> Bool
  func run(validator:ValidatorType) throws
  
}

extension Field{
  
  public func validate() -> Bool{
    errors.removeAll()
    var stopValidation = validateRequired()
    for validator in validators{
      if stopValidation{
        break
      }
      stopValidation = tryRun(validator: validator)
    }
    return errors.isEmpty
  }
  
  func validateRequired() -> Bool{
    if isRequired{
      if data == nil{
        errors.append(ValidationError(message: "This field is required."))
        return true
      }
    }else{
      // If value is optional, nil value will stop descendents validate
      return data == nil
    }
    return false
  }
  
  func tryRun(validator:ValidatorType) -> Bool{
    do{
      try run(validator: validator)
    }catch let error as StopValidation{
      errors.append(error)
      return true
    }catch let error as ValueError{
      errors.append(error)
    }catch let error{
      errors.append(ValidationError(message: "Unknow Error: \(error.localizedDescription)"))
    }
    return false
    
  }
}

extension Field where Self.ValueType: Equatable{
  public func validateEqualTo(other:Self, message:String? = nil)throws{
    if data != other.data{
      let msg = message ?? "Field must equal to \(other.name)"
      throw ValidationError(message: msg)
    }
  }
}

extension Field where Self.ValueType == String{
  public func validateLength(min:Int? = nil,max:Int? = nil, message:String? = nil)throws{
    assert(min != nil || max != nil)
    assert(max == nil || min! <= max!)
    
    let len = data?.characters.count ?? 0
    if let min = min, let max = max {
      if !(len >= min && len <= max){
        throw ValidationError(message: "Field must be between \(min) and \(max) characters long.")
      }
    }else if let min = min{
      if len < min{
        throw ValidationError(message: "Field must be at least \(min) characters long.")
      }
    }else if let max = max{
      if len > max{
        throw ValidationError(message: "Field cannot be longer than \(max) characters")
      }
    }
  }
  
  public func validateRegex(pattern:String, message:String?=nil) throws{
    guard let text = data else{
      fatalError("data is nil")
      return
    }
    let exp = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    let count = exp.numberOfMatches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count))
    
    if count == 1{
      throw ValidationError(message: message ?? "Invalid input")
    }
  }
}

public enum StringValidator{
  case length(min:Int?, max:Int?,message:String?)
  case regex(pattern:String, message:String?)
}

open class StringField: Field{
  public var data: String?
  public var placeholder: String?
  
  public var description: String?
  
  public var errors: [FormError] = []
  
  public var label: String?
  
  public let name:String
  
  public let widget = UITextField()
  
  public  let validators:[StringValidator]
  public let  isRequired: Bool
  
  public init(name:String, label:String?=nil, description:String?=nil, validators:[StringValidator]  = [], isRequired:Bool = true){
    self.name = name
    self.label = label
    self.description = description
    self.validators = validators
    self.isRequired = isRequired
    afterInit()
  }
  
  open func afterInit(){
    
  }
  
  public func run(validator:StringValidator) throws{
    switch validator {
    case .length(let min, let max, let message):
      try validateLength(min: min, max: max, message: message)
    default:
      break
    }
    
  }
  
}

open class TextField: StringField{
  
}

open class PasswordField: TextField{
  
  open override func afterInit() {
    super.afterInit()
    widget.isSecureTextEntry = true
  }
  
}

public enum BooleanValidator{
  
}

open class BooleanField: Field{
  
  public var validators: [BooleanValidator] = []
  
  public var description: String?
  
  public var label: String?
  
  public var name: String = ""
  
  
  public var errors: [FormError] = []
  
  public var placeholder: Bool?
  
  
  public var data: Bool?
  
  public let widget = UISwitch()
  
  public let  isRequired: Bool
  public let validatos: [BooleanValidator] = []
  
  public init(name:String, label:String?=nil, description:String?=nil, isRequired:Bool = false ){
    self.name = name
    self.label = label
    self.description = description
    self.isRequired = isRequired
  }
  
  
  public func run(validator: BooleanValidator) throws {
  }
  
  
  
}

public protocol FormError:Error{
  var message:String { get }
}

public class ValueError:FormError{
  public let message:String
  
  public init(message:String = ""){
    self.message = message
  }
}

public class ValidationError: ValueError{
  
}

public class StopValidation:FormError{
  public let message:String
  
  public init(message:String = ""){
    self.message = message
  }
}

open class BaseForm{
  open func validate(fields:[Any]) -> Bool{
    var success = true
    for field in fields{
      switch field {
      case let field as StringField:
        success = field.validate()
      case let field as BooleanField:
        success = field.validate()
      default:
        fatalError("Unkown type of field \(field)")
      }
      
    }
    return success
    
  }
}
