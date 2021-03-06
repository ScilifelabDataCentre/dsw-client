module Models exposing
    ( Flags
    , Model
    , defaultFlags
    , flagsDecoder
    , initLocalModel
    , initialModel
    , setJwt
    , setRoute
    , setSeed
    , setSession
    , userLoggedIn
    )

import Auth.Models exposing (JwtToken, Session, sessionDecoder, sessionExists)
import Common.AppState exposing (AppState)
import Common.Config as Config exposing (Config)
import Common.Menu.Models
import Common.Provisioning as Provisioning exposing (Provisioning)
import Dashboard.Models
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import KMEditor.Models
import KnowledgeModels.Models
import Organization.Models
import Public.Models
import Questionnaires.Models
import Random exposing (Seed)
import Routes
import Users.Models


type alias Model =
    { appState : AppState
    , menuModel : Common.Menu.Models.Model
    , dashboardModel : Dashboard.Models.Model
    , organizationModel : Organization.Models.Model
    , kmEditorModel : KMEditor.Models.Model
    , kmPackagesModel : KnowledgeModels.Models.Model
    , publicModel : Public.Models.Model
    , questionnairesModel : Questionnaires.Models.Model
    , users : Users.Models.Model
    }


initialModel : AppState -> Model
initialModel appState =
    { appState = appState
    , menuModel = Common.Menu.Models.initialModel
    , dashboardModel = Dashboard.Models.initialModel
    , organizationModel = Organization.Models.initialModel
    , kmEditorModel = KMEditor.Models.initialModel
    , kmPackagesModel = KnowledgeModels.Models.initialModel appState
    , questionnairesModel = Questionnaires.Models.initialModel
    , publicModel = Public.Models.initialModel
    , users = Users.Models.initialModel
    }


setSession : Session -> Model -> Model
setSession session model =
    let
        appState =
            model.appState

        newState =
            { appState | session = session }
    in
    { model | appState = newState }


setJwt : Maybe JwtToken -> Model -> Model
setJwt jwt model =
    let
        appState =
            model.appState

        newState =
            { appState | jwt = jwt }
    in
    { model | appState = newState }


setRoute : Routes.Route -> Model -> Model
setRoute route model =
    let
        appState =
            model.appState

        newState =
            { appState | route = route }
    in
    { model | appState = newState }


setSeed : Seed -> Model -> Model
setSeed seed model =
    let
        appState =
            model.appState

        newState =
            { appState | seed = seed }
    in
    { model | appState = newState }


initLocalModel : Model -> Model
initLocalModel model =
    case model.appState.route of
        Routes.OrganizationRoute ->
            { model | organizationModel = Organization.Models.initialModel }

        Routes.KMEditorRoute route ->
            { model | kmEditorModel = KMEditor.Models.initLocalModel route model.kmEditorModel }

        Routes.KnowledgeModelsRoute route ->
            { model | kmPackagesModel = KnowledgeModels.Models.initLocalModel route model.appState model.kmPackagesModel }

        Routes.PublicRoute route ->
            { model | publicModel = Public.Models.initLocalModel route model.publicModel }

        Routes.QuestionnairesRoute route ->
            { model | questionnairesModel = Questionnaires.Models.initLocalModel route model.questionnairesModel }

        Routes.UsersRoute route ->
            { model | users = Users.Models.initLocalModel route model.users }

        _ ->
            model


userLoggedIn : Model -> Bool
userLoggedIn model =
    sessionExists model.appState.session


type alias Flags =
    { session : Maybe Session
    , seed : Int
    , apiUrl : String
    , config : Config
    , provisioning : Provisioning
    , success : Bool
    }


flagsDecoder : Decoder Flags
flagsDecoder =
    Decode.succeed Flags
        |> required "session" (Decode.nullable sessionDecoder)
        |> required "seed" Decode.int
        |> required "apiUrl" Decode.string
        |> required "config" Config.decoder
        |> optional "provisioning" Provisioning.decoder Provisioning.default
        |> hardcoded True


defaultFlags : Flags
defaultFlags =
    { session = Nothing
    , seed = 0
    , apiUrl = ""
    , config = Config.defaultConfig
    , provisioning = Provisioning.default
    , success = False
    }
