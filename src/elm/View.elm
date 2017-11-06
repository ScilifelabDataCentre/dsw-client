module View exposing (..)

import Auth.Msgs
import Auth.Permission as Perm exposing (hasPerm)
import Auth.View
import Common.Html exposing (defaultFullPageError, fullPageError, linkTo, onLinkClick)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import KnowledgeModels.Create.View
import KnowledgeModels.Editor.View
import KnowledgeModels.Index.View
import Models exposing (Model)
import Msgs exposing (Msg)
import Routing exposing (Route(..))
import UserManagement.Create.View
import UserManagement.Delete.View
import UserManagement.Edit.View
import UserManagement.Index.View


view : Model -> Html Msg
view model =
    case model.route of
        Login ->
            Auth.View.view model.authModel

        Index ->
            appView model indexView

        Organization ->
            appView model organizationView

        UserManagement ->
            appView model <| UserManagement.Index.View.view model.userManagementIndexModel

        UserManagementCreate ->
            appView model <| UserManagement.Create.View.view model.userManagementCreateModel

        UserManagementEdit uuid ->
            appView model <| UserManagement.Edit.View.view model.userManagementEditModel

        UserManagementDelete uuid ->
            appView model <| UserManagement.Delete.View.view model.userManagementDeleteModel

        KnowledgeModelsCreate ->
            appView model KnowledgeModels.Create.View.view

        KnowledgeModelsEditor ->
            appView model KnowledgeModels.Editor.View.view

        KnowledgeModels ->
            appView model KnowledgeModels.Index.View.view

        Wizzards ->
            appView model wizzardsView

        DataManagementPlans ->
            appView model dataManagementPlansView

        NotFound ->
            appView model notFoundView

        NotAllowed ->
            appView model notAllowedView


appView : Model -> Html Msg -> Html Msg
appView model content =
    div [ class "app-view" ]
        [ menu model
        , div [ class "page" ]
            [ content ]
        ]


menuItems : List ( String, String, Route, String )
menuItems =
    [ ( "Organization", "fa-building", Organization, Perm.organization )
    , ( "User Management", "fa-users", UserManagement, Perm.userManagement )
    , ( "Knowledge Models", "fa-database", KnowledgeModels, Perm.knowledgeModel )
    , ( "Wizzards", "fa-list-alt", Wizzards, Perm.wizzard )
    , ( "Data Management Plans", "fa-file-text", DataManagementPlans, Perm.dataManagementPlan )
    ]


menu : Model -> Html Msg
menu model =
    div [ class "side-navigation" ]
        [ logo
        , ul [ class "menu" ]
            (createMenu model)
        , profileInfo model
        ]


logo : Html Msg
logo =
    linkTo Index
        [ class "logo" ]
        [ text "Elixir DSP" ]


createMenu : Model -> List (Html Msg)
createMenu model =
    menuItems
        |> List.filter (\( _, _, _, perm ) -> hasPerm model.jwt perm)
        |> List.map (menuItem model)


menuItem : Model -> ( String, String, Route, String ) -> Html Msg
menuItem model ( label, icon, route, perm ) =
    let
        activeClass =
            if model.route == route then
                "active"
            else
                ""
    in
    li []
        [ linkTo route
            [ class activeClass ]
            [ i [ class ("fa " ++ icon) ] []
            , text label
            ]
        ]


profileInfo : Model -> Html Msg
profileInfo model =
    let
        name =
            case model.session.user of
                Just user ->
                    user.name ++ " " ++ user.surname

                Nothing ->
                    ""
    in
    div [ class "profile-info" ]
        [ linkTo (UserManagementEdit "current") [ class "name" ] [ text name ]
        , a [ onLinkClick (Msgs.AuthMsg Auth.Msgs.Logout) ]
            [ i [ class "fa fa-sign-out" ] []
            , text "Logout"
            ]
        ]


indexView : Html Msg
indexView =
    text "Welcome to DSP!"


organizationView : Html Msg
organizationView =
    text "Organization"


wizzardsView : Html Msg
wizzardsView =
    text "Wizzards"


dataManagementPlansView : Html Msg
dataManagementPlansView =
    text "Data Management Plans"


notFoundView : Html msg
notFoundView =
    fullPageError "fa-file-o" "The page was not found"


notAllowedView : Html msg
notAllowedView =
    fullPageError "fa-ban" "You don't have a permission to view this page"
