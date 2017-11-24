module KnowledgeModels.Requests exposing (..)

import Auth.Models exposing (Session)
import Http
import Json.Encode exposing (Value)
import KnowledgeModels.Editor.Models.Entities as Editor exposing (KnowledgeModel, knowledgeModelDecoder)
import KnowledgeModels.Models as Models exposing (KnowledgeModel, knowledgeModelDecoder, knowledgeModelListDecoder)
import Requests


getKnowledgeModel : String -> Session -> Http.Request Models.KnowledgeModel
getKnowledgeModel uuid session =
    Requests.get session ("/branches/" ++ uuid) Models.knowledgeModelDecoder


getKnowledgeModels : Session -> Http.Request (List Models.KnowledgeModel)
getKnowledgeModels session =
    Requests.get session "/branches" knowledgeModelListDecoder


postKnowledgeModel : Session -> Value -> Http.Request String
postKnowledgeModel session knowledgeModel =
    Requests.post knowledgeModel session "/branches"


deleteKnowledgeModel : String -> Session -> Http.Request String
deleteKnowledgeModel uuid session =
    Requests.delete session ("/branches/" ++ uuid)


putKnowledgeModelVersion : String -> String -> Value -> Session -> Http.Request String
putKnowledgeModelVersion kmUuid version data session =
    Requests.put data session ("/branches/" ++ kmUuid ++ "/versions/" ++ version)


getKnowledgeModelData : String -> Session -> Http.Request Editor.KnowledgeModel
getKnowledgeModelData uuid session =
    Requests.get session ("/branches/" ++ uuid ++ "/km") Editor.knowledgeModelDecoder


postEventsBulk : Session -> String -> Value -> Http.Request String
postEventsBulk session uuid data =
    Requests.post data session ("/branches/" ++ uuid ++ "/events/_bulk")
