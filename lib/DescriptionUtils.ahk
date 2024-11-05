
class DescriptionUtils {

    static getAhkDescription(ahkFile) {
        text := FileRead(ahkFile, "UTF-8 m1024")
        descriptionStart := InStr(text, "@description")
        if descriptionStart > 0 {
            descriptionStart := descriptionStart + 13
            descriptionEnd := InStr(text, "`n", ,descriptionStart)
            return SubStr(text, descriptionStart, descriptionEnd - descriptionStart)
        }
        return ""
    }

    
}