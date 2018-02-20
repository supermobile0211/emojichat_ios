//
//  CountryUtils.swift
//  EmijiChat
//
//  Created by Star on 10/17/17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import Foundation
import CoreTelephony

struct Country {
    var iso: String
    var code: String
    var name: String
}

class CountryUtils {
    
    private init() {}
    static let shared = CountryUtils()
    
    func getAllCountries() -> [Country] {
        let Countries: [Country] = [
            Country(iso: "AF", code: "+93", name: "Afghanistan"),
            Country(iso: "AL", code: "+355", name: "Albania"),
            Country(iso: "DZ", code: "+213", name: "Algeria"),
            Country(iso: "AS", code: "+1 684", name: "American Samoa"),
            Country(iso: "AD", code: "+376", name: "Andorra"),
            Country(iso: "AO", code: "+244", name: "Angola"),
            Country(iso: "AI", code: "+1 264", name: "Anguilla"),
            Country(iso: "AG", code: "+1 268", name: "Antigua and Barbuda"),
            Country(iso: "AR", code: "+54", name: "Argentina"),
            Country(iso: "AM", code: "+374", name: "Armenia"),
            Country(iso: "AW", code: "+297", name: "Aruba"),
            Country(iso: "AU", code: "+61", name: "Australia"),
            Country(iso: "AQ", code: "+672", name: "Australian External Territories"),
            Country(iso: "AT", code: "+43", name: "Austria"),
            Country(iso: "AZ", code: "+994", name: "Azerbaijan"),
            Country(iso: "BS", code: "+1 242", name: "Bahamas"),
            Country(iso: "BH", code: "+973", name: "Bahrain"),
            Country(iso: "BD", code: "+880", name: "Bangladesh"),
            Country(iso: "BB", code: "+1 246", name: "Barbados"),
            Country(iso: "BY", code: "+375", name: "Belarus"),
            Country(iso: "BE", code: "+32", name: "Belgium"),
            Country(iso: "BZ", code: "+501", name: "Belize"),
            Country(iso: "BJ", code: "+229", name: "Benin"),
            Country(iso: "BM", code: "+1 441", name: "Bermuda"),
            Country(iso: "BT", code: "+975", name: "Bhutan"),
            Country(iso: "BO", code: "+591", name: "Bolivia"),
            Country(iso: "BA", code: "+387", name: "Bosnia and Herzegovina"),
            Country(iso: "BW", code: "+267", name: "Botswana"),
            Country(iso: "BR", code: "+55", name: "Brazil"),
            Country(iso: "IO", code: "+246", name: "British Indian Ocean Territory"),
            Country(iso: "VG", code: "+1 284", name: "British Virgin Islands"),
            Country(iso: "BN", code: "+673", name: "Brunei"),
            Country(iso: "BG", code: "+359", name: "Bulgaria"),
            Country(iso: "BF", code: "+226", name: "Burkina Faso"),
            Country(iso: "BI", code: "+257", name: "Burundi"),
            Country(iso: "KH", code: "+855", name: "Cambodia"),
            Country(iso: "CM", code: "+237", name: "Cameroon"),
            Country(iso: "CA", code: "+1", name: "Canada"),
            Country(iso: "CV", code: "+238", name: "Cape Verde"),
            Country(iso: "KY", code: "+ 345", name: "Cayman Islands"),
            Country(iso: "CF", code: "+236", name: "Central African Republic"),
            Country(iso: "TD", code: "+235", name: "Chad"),
            Country(iso: "CL", code: "+56", name: "Chile"),
            Country(iso: "CN", code: "+86", name: "China"),
            Country(iso: "CX", code: "+61", name: "Christmas Island"),
            Country(iso: "CC", code: "+61", name: "Cocos-Keeling Islands"),
            Country(iso: "CO", code: "+57", name: "Colombia"),
            Country(iso: "KM", code: "+269", name: "Comoros"),
            Country(iso: "CG", code: "+242", name: "Republic of the Congo"),
            Country(iso: "CD", code: "+243", name: "Congo, Dem. Rep. of (Zaire)"),
            Country(iso: "CK", code: "+682", name: "Cook Islands"),
            Country(iso: "CR", code: "+506", name: "Costa Rica"),
            Country(iso: "HR", code: "+385", name: "Croatia"),
            Country(iso: "CU", code: "+53", name: "Cuba"),
            Country(iso: "CW", code: "+599", name: "Curacao"),
            Country(iso: "CY", code: "+537", name: "Cyprus"),
            Country(iso: "CZ", code: "+420", name: "Czech Republic"),
            Country(iso: "DK", code: "+45", name: "Denmark"),
            Country(iso: "", code: "+246", name: "Diego Garcia"),
            Country(iso: "DJ", code: "+253", name: "Djibouti"),
            Country(iso: "DM", code: "+1 767", name: "Dominica"),
            Country(iso: "DO", code: "+1 809", name: "Dominican Republic"),
            Country(iso: "TL", code: "+670", name: "East Timor"),
            Country(iso: "EC", code: "+593", name: "Ecuador"),
            Country(iso: "EG", code: "+20", name: "Egypt"),
            Country(iso: "SV", code: "+503", name: "El Salvador"),
            Country(iso: "GQ", code: "+240", name: "Equatorial Guinea"),
            Country(iso: "ER", code: "+291", name: "Eritrea"),
            Country(iso: "EE", code: "+372", name: "Estonia"),
            Country(iso: "ET", code: "+251", name: "Ethiopia"),
            Country(iso: "FK", code: "+500", name: "Falkland Islands"),
            Country(iso: "FO", code: "+298", name: "Faroe Islands"),
            Country(iso: "FJ", code: "+679", name: "Fiji"),
            Country(iso: "FI", code: "+358", name: "Finland"),
            Country(iso: "FR", code: "+33", name: "France"),
            Country(iso: "PF", code: "+689", name: "French Polynesia"),
            Country(iso: "GA", code: "+241", name: "Gabon"),
            Country(iso: "GM", code: "+220", name: "Gambia"),
            Country(iso: "GE", code: "+995", name: "Georgia"),
            Country(iso: "DE", code: "+49", name: "Germany"),
            Country(iso: "GH", code: "+233", name: "Ghana"),
            Country(iso: "GI", code: "+350", name: "Gibraltar"),
            Country(iso: "GR", code: "+30", name: "Greece"),
            Country(iso: "GL", code: "+299", name: "Greenland"),
            Country(iso: "GD", code: "+1 473", name: "Grenada"),
            Country(iso: "BL", code: "+590", name: "Saint Barthelemy"),
            Country(iso: "GU", code: "+1 671", name: "Guam"),
            Country(iso: "GT", code: "+502", name: "Guatemala"),
            Country(iso: "GN", code: "+224", name: "Guinea"),
            Country(iso: "GW", code: "+245", name: "Guinea-Bissau"),
            Country(iso: "GY", code: "+595", name: "Guyana"),
            Country(iso: "HT", code: "+509", name: "Haiti"),
            Country(iso: "HN", code: "+504", name: "Honduras"),
            Country(iso: "HK", code: "+852", name: "Hong Kong SAR China"),
            Country(iso: "HU", code: "+36", name: "Hungary"),
            Country(iso: "IS", code: "+354", name: "Iceland"),
            Country(iso: "IN", code: "+91", name: "India"),
            Country(iso: "ID", code: "+62", name: "Indonesia"),
            Country(iso: "IR", code: "+98", name: "Iran"),
            Country(iso: "IQ", code: "+964", name: "Iraq"),
            Country(iso: "IE", code: "+353", name: "Ireland"),
            Country(iso: "IL", code: "+972", name: "Israel"),
            Country(iso: "IT", code: "+39", name: "Italy"),
            Country(iso: "CI", code: "+225", name: "Ivory Coast"),
            Country(iso: "JM", code: "+1 876", name: "Jamaica"),
            Country(iso: "JP", code: "+81", name: "Japan"),
            Country(iso: "JO", code: "+962", name: "Jordan"),
            Country(iso: "KZ", code: "+7 7", name: "Kazakhstan"),
            Country(iso: "KE", code: "+254", name: "Kenya"),
            Country(iso: "KI", code: "+686", name: "Kiribati"),
            Country(iso: "KW", code: "+965", name: "Kuwait"),
            Country(iso: "KG", code: "+996", name: "Kyrgyzstan"),
            Country(iso: "LA", code: "+856", name: "Laos"),
            Country(iso: "LV", code: "+371", name: "Latvia"),
            Country(iso: "LB", code: "+961", name: "Lebanon"),
            Country(iso: "LS", code: "+266", name: "Lesotho"),
            Country(iso: "LR", code: "+231", name: "Liberia"),
            Country(iso: "LY", code: "+218", name: "Libya"),
            Country(iso: "LI", code: "+423", name: "Liechtenstein"),
            Country(iso: "LT", code: "+370", name: "Lithuania"),
            Country(iso: "LU", code: "+352", name: "Luxembourg"),
            Country(iso: "MO", code: "+853", name: "Macau SAR China"),
            Country(iso: "MK", code: "+389", name: "Macedonia"),
            Country(iso: "MG", code: "+261", name: "Madagascar"),
            Country(iso: "MW", code: "+265", name: "Malawi"),
            Country(iso: "MY", code: "+60", name: "Malaysia"),
            Country(iso: "MV", code: "+960", name: "Maldives"),
            Country(iso: "ML", code: "+223", name: "Mali"),
            Country(iso: "MT", code: "+356", name: "Malta"),
            Country(iso: "MH", code: "+692", name: "Marshall Islands"),
            Country(iso: "MR", code: "+222", name: "Mauritania"),
            Country(iso: "MU", code: "+230", name: "Mauritius"),
            Country(iso: "YT", code: "+262", name: "Mayotte"),
            Country(iso: "MX", code: "+52", name: "Mexico"),
            Country(iso: "FM", code: "+691", name: "Micronesia"),
            Country(iso: "MD", code: "+373", name: "Moldova"),
            Country(iso: "MC", code: "+377", name: "Monaco"),
            Country(iso: "MN", code: "+976", name: "Mongolia"),
            Country(iso: "ME", code: "+382", name: "Montenegro"),
            Country(iso: "MS", code: "+1664", name: "Montserrat"),
            Country(iso: "MA", code: "+212", name: "Morocco"),
            Country(iso: "MM", code: "+95", name: "Myanmar"),
            Country(iso: "NA", code: "+264", name: "Namibia"),
            Country(iso: "NR", code: "+674", name: "Nauru"),
            Country(iso: "NP", code: "+977", name: "Nepal"),
            Country(iso: "NL", code: "+31", name: "Netherlands"),
            Country(iso: "AN", code: "+599", name: "Netherlands Antilles"),
            Country(iso: "KN", code: "+1 869", name: "Saint Kitts and Nevis"),
            Country(iso: "NC", code: "+687", name: "New Caledonia"),
            Country(iso: "NZ", code: "+64", name: "New Zealand"),
            Country(iso: "NI", code: "+505", name: "Nicaragua"),
            Country(iso: "NE", code: "+227", name: "Niger"),
            Country(iso: "NG", code: "+234", name: "Nigeria"),
            Country(iso: "NU", code: "+683", name: "Niue"),
            Country(iso: "AQ", code: "+672", name: "Antarctica"),
            Country(iso: "KP", code: "+850", name: "North Korea"),
            Country(iso: "MP", code: "+1 670", name: "Northern Mariana Islands"),
            Country(iso: "NO", code: "+47", name: "Norway"),
            Country(iso: "OM", code: "+968", name: "Oman"),
            Country(iso: "PK", code: "+92", name: "Pakistan"),
            Country(iso: "PW", code: "+680", name: "Palau"),
            Country(iso: "PS", code: "+970", name: "Palestinian Territory"),
            Country(iso: "PA", code: "+507", name: "Panama"),
            Country(iso: "PG", code: "+675", name: "Papua New Guinea"),
            Country(iso: "PY", code: "+595", name: "Paraguay"),
            Country(iso: "PE", code: "+51", name: "Peru"),
            Country(iso: "PH", code: "+63", name: "Philippines"),
            Country(iso: "PL", code: "+48", name: "Poland"),
            Country(iso: "PT", code: "+351", name: "Portugal"),
            Country(iso: "PR", code: "+1 787", name: "Puerto Rico"),
            Country(iso: "QA", code: "+974", name: "Qatar"),
            Country(iso: "RE", code: "+262", name: "Reunion"),
            Country(iso: "RO", code: "+40", name: "Romania"),
            Country(iso: "RU", code: "+7", name: "Russia"),
            Country(iso: "RW", code: "+250", name: "Rwanda"),
            Country(iso: "WS", code: "+685", name: "Samoa"),
            Country(iso: "SM", code: "+378", name: "San Marino"),
            Country(iso: "SA", code: "+966", name: "Saudi Arabia"),
            Country(iso: "SN", code: "+221", name: "Senegal"),
            Country(iso: "RS", code: "+381", name: "Serbia"),
            Country(iso: "SC", code: "+248", name: "Seychelles"),
            Country(iso: "SL", code: "+232", name: "Sierra Leone"),
            Country(iso: "SG", code: "+65", name: "Singapore"),
            Country(iso: "SK", code: "+421", name: "Slovakia"),
            Country(iso: "SI", code: "+386", name: "Slovenia"),
            Country(iso: "SB", code: "+677", name: "Solomon Islands"),
            Country(iso: "ZA", code: "+27", name: "South Africa"),
            Country(iso: "FK", code: "+500", name: "Falkland Islands"),
            Country(iso: "KR", code: "+82", name: "South Korea"),
            Country(iso: "ES", code: "+34", name: "Spain"),
            Country(iso: "LK", code: "+94", name: "Sri Lanka"),
            Country(iso: "SD", code: "+249", name: "Sudan"),
            Country(iso: "SR", code: "+597", name: "Suriname"),
            Country(iso: "SZ", code: "+268", name: "Swaziland"),
            Country(iso: "SE", code: "+46", name: "Sweden"),
            Country(iso: "CH", code: "+41", name: "Switzerland"),
            Country(iso: "SY", code: "+963", name: "Syria"),
            Country(iso: "TW", code: "+886", name: "Taiwan"),
            Country(iso: "TJ", code: "+992", name: "Tajikistan"),
            Country(iso: "TZ", code: "+255", name: "Tanzania"),
            Country(iso: "TH", code: "+66", name: "Thailand"),
            Country(iso: "TL", code: "+670", name: "East Timor"),
            Country(iso: "TG", code: "+228", name: "Togo"),
            Country(iso: "TK", code: "+690", name: "Tokelau"),
            Country(iso: "TO", code: "+676", name: "Tonga"),
            Country(iso: "TT", code: "+1 868", name: "Trinidad and Tobago"),
            Country(iso: "TN", code: "+216", name: "Tunisia"),
            Country(iso: "TR", code: "+90", name: "Turkey"),
            Country(iso: "TM", code: "+993", name: "Turkmenistan"),
            Country(iso: "TC", code: "+1 649", name: "Turks and Caicos Islands"),
            Country(iso: "TV", code: "+688", name: "Tuvalu"),
            Country(iso: "VI", code: "+1 340", name: "U.S. Virgin Islands"),
            Country(iso: "UG", code: "+256", name: "Uganda"),
            Country(iso: "UA", code: "+380", name: "Ukraine"),
            Country(iso: "AE", code: "+971", name: "United Arab Emirates"),
            Country(iso: "GB", code: "+44", name: "United Kingdom"),
            Country(iso: "US", code: "+1", name: "United States"),
            Country(iso: "UY", code: "+598", name: "Uruguay"),
            Country(iso: "UZ", code: "+998", name: "Uzbekistan"),
            Country(iso: "VU", code: "+678", name: "Vanuatu"),
            Country(iso: "VE", code: "+58", name: "Venezuela"),
            Country(iso: "VN", code: "+84", name: "Vietnam"),
            Country(iso: "WF", code: "+681", name: "Wallis and Futuna"),
            Country(iso: "YE", code: "+967", name: "Yemen"),
            Country(iso: "ZM", code: "+260", name: "Zambia"),
            Country(iso: "TZ", code: "+255", name: "Tanzania"),
            Country(iso: "ZW", code: "+263", name: "Zimbabwe")
        ]
        
        return Countries
    }
    
    func getCountryInfo(by iso: String) -> Country? {
        if !iso.isEmpty {
            for country in getAllCountries() {
                if country.iso == iso.uppercased() {
                    return country
                }
            }
        }
        return nil
    }
    
    func getSIMCountryCode() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        if let icc = carrier?.isoCountryCode {
            print("ISOCountryCode: \(icc)")
            return icc
        }
        return ""
    }
    
    func getCurrentCountryInfo() -> Country? {
        return getCountryInfo(by: getSIMCountryCode())
    }    
}
