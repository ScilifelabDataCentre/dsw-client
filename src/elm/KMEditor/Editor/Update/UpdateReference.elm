module KMEditor.Editor.Update.UpdateReference exposing (..)

{-|

@docs updateReferenceFormMsg, updateReferenceCancel

-}

import Form
import KMEditor.Editor.Models.Editors exposing (..)
import KMEditor.Editor.Models.Entities exposing (..)
import KMEditor.Editor.Models.Events exposing (Event, createEditReferenceEvent)
import KMEditor.Editor.Models.Forms exposing (initReferenceForm, referenceFormValidation, updateReferenceWithForm)
import KMEditor.Editor.Update.Utils exposing (formChanged)
import Random.Pcg exposing (Seed)


{-| -}
updateReferenceFormMsg : Form.Msg -> Seed -> Question -> Chapter -> KnowledgeModel -> ReferenceEditor -> ( Seed, ReferenceEditor, Maybe Event )
updateReferenceFormMsg formMsg seed question chapter knowledgeModel ((ReferenceEditor editor) as originalEditor) =
    case ( formMsg, Form.getOutput editor.form, formChanged editor.form ) of
        ( Form.Submit, Just referenceForm, True ) ->
            let
                newReference =
                    updateReferenceWithForm editor.reference referenceForm

                newForm =
                    initReferenceForm newReference

                newEditor =
                    { editor | active = False, form = newForm, reference = newReference }

                ( event, newSeed ) =
                    createEditReferenceEvent question chapter knowledgeModel [] seed newReference
            in
            ( newSeed, ReferenceEditor { editor | active = False }, Just event )

        ( Form.Submit, Just referenceForm, False ) ->
            ( seed, ReferenceEditor { editor | active = False }, Nothing )

        _ ->
            let
                newForm =
                    Form.update referenceFormValidation formMsg editor.form
            in
            ( seed, ReferenceEditor { editor | form = newForm }, Nothing )


{-| -}
updateReferenceCancel : Seed -> ReferenceEditor -> ( Seed, ReferenceEditor, Maybe Event )
updateReferenceCancel seed (ReferenceEditor editor) =
    let
        newForm =
            initReferenceForm editor.reference
    in
    ( seed, ReferenceEditor { editor | active = False, form = newForm }, Nothing )