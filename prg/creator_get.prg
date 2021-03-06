#include "hbclass.ch"
#include "inkey.ch"

#include "creator.ch"

CLASS Creator_get INHERIT Creator

EXPORTED:

    METHOD edit_form(xFormCode, xGetPos)

HIDDEN:

    METHOD __refresh_and_display(nTop, nLeft, nBottom, nRight, nOldWindow, xFormCode, xGetPos, aoWasGetList, cScreen)

ENDCLASS LOCK

METHOD __refresh_and_display(nTop, nLeft, nBottom, nRight, nOldWindow, xFormCode, xGetPos, aoWasGetList, cScreen) CLASS Creator_get

    MEMVAR GETLIST

    DispBegin()

    IF Alias() == 'DBREORDER'

        CLEAR GETS

        IF WSelect() > 0
            WClose()
        ELSE
            RESTORE SCREEN FROM cScreen
        ENDIF

        prepare_form(ACopy(xFormCode, Array(field->line_nr - 1), 1, field->line_nr - 1))
        ::_display_form()
        prepare_form(ACopy(xFormCode, Array(Len(xFormCode) - field->line_nr), field->line_nr + 1))
    ELSE
        IF WSelect() > 0
            WSelect(0)
            RestScreen(nTop, nLeft, nBottom, nRight, cScreen)
            WSelect(nOldWindow)
        ELSE
            RESTORE SCREEN FROM cScreen
        ENDIF

        ::_display_form()
    ENDIF

    IF ValType(aoWasGetList) == 'A' .AND. Len(aoWasGetList) != 0 .AND. Len(GETLIST) != 0
        IF ValType(xFormCode) == 'A'
            aoWasGetList[xGetPos] := __objClone(GETLIST[xGetPos])
        ELSE
            aoWasGetList[Len(aoWasGetList)] := __objClone(ATail(GETLIST))
        ENDIF
    ELSE
        aoWasGetList := clone_objects_array(GETLIST)
    ENDIF
    
    GETLIST := ASize(GETLIST, Len(GETLIST) - 1)

    DispEnd()

RETURN NIL

METHOD edit_form(xFormCode, xGetPos) CLASS Creator_get

    MEMVAR GETLIST

    LOCAL cOldHeader := Window():header(Config():get_config('CreatorGetHeader'))
    LOCAL cOldFooter := Window():footer(Config():get_config('CreatorGetFooter'))
    LOCAL nOldWindow := WSelect()
    LOCAL nTopLimit := IF(WSelect() == 0, Window():get_top(), 0)
    LOCAL nLeftLimit := IF(WSelect() == 0, Window():get_left(), 0)
    LOCAL nBottomLimit := IF(WSelect() == 0, Window():get_bottom(), MaxRow() - 1)
    LOCAL nRightLimit := IF(WSelect() == 0, Window():get_right(), MaxCol() - 1)
    LOCAL lFinish := .F.
    LOCAL nTop := WRow()
    LOCAL nLeft := WCol()
    LOCAL nBottom := WLastRow()
    LOCAL nRight := WLastCol()
    LOCAL lSave := .F.
    LOCAL nMouseRow
    LOCAL nMouseCol
    LOCAL lRefresh
    LOCAL aoWasGetList
    LOCAL cScreen
    LOCAL nKey

    IF nOldWindow > 0
        WSelect(0)
        cScreen := SaveScreen(nTop, nLeft, nBottom, nRight)
        WSelect(nOldWindow)

        Window():refresh_header_footer()

        WClose()
    ELSE
        Window():refresh_header_footer()

        CLEAR GETS

        IF ValType(xFormCode) == 'A'
            SAVE SCREEN TO cScreen
        ENDIF

        IF !prepare_form(xFormCode)
            lFinish := .T.
            Inform(Parser():log(''))
        ELSEIF ValType(xFormCode) != 'A'
            SAVE SCREEN TO cScreen
        ENDIF
    ENDIF

    IF !lFinish
        ::_set_type(OBJECT_GET)

        CLEAR GETS

        IF !prepare_form(xFormCode)
            lFinish := .T.
            Inform(Parser():log(''))
        ELSE
            ::_make_form_array(xFormCode)

            IF Alias() == 'DBREORDER'
                GETLIST[xGetPos] := __objClone(ATail(GETLIST))
                GETLIST := ASize(GETLIST, Len(GETLIST) - 1)
            ENDIF
        ENDIF
    ENDIF

    DO WHILE !lFinish

        ::__refresh_and_display(nTop, nLeft, nBottom, nRight, nOldWindow, xFormCode, xGetPos, @aoWasGetList, cScreen)

        nKey := Inkey(0)

        DO CASE
            CASE nKey == K_UP
                IF ::_get_value(N_ROW_GET) >= nTopLimit
                    ::_decrement(N_ROW_GET)
                ENDIF
            CASE nKey == K_LEFT
                IF ::_get_value(N_COL_GET) >= nLeftLimit
                    ::_decrement(N_COL_GET)
                ENDIF
            CASE nKey == K_DOWN
                IF ::_get_value(N_ROW_GET) <= nBottomLimit
                    ::_increment(N_ROW_GET)
                ENDIF
            CASE nKey == K_RIGHT
                IF ::_get_value(N_COL_GET) <= nRightLimit
                    ::_increment(N_COL_GET)
                ENDIF
            CASE nKey == K_ENTER
                ::_form_fast_edit(nTop, nLeft, nBottom, nRight, cScreen, xFormCode, xGetPos)
            CASE nKey == K_ALT_ENTER
                IF YesNo(Config():get_config('DoReadOrder'))
                    ReadModal(aoWasGetList)
                ENDIF
            CASE nKey == K_LBUTTONDOWN

                nKey := 0

                DO WHILE nKey == K_MOUSEMOVE .OR. nKey == 0

                    nKey := Inkey()

                    nMouseRow := MRow()
                    nMouseCol := MCol()
                    lRefresh := .F.

                    IF nMouseRow > ::_get_value(N_ROW_GET)
                        IF ::_get_value(N_ROW_GET) <= nBottomLimit
                            ::_increment(N_ROW_GET)
                            lRefresh := .T.
                        ENDIF
                    ELSEIF nMouseRow < ::_get_value(N_ROW_GET)
                        IF ::_get_value(N_ROW_GET) >= nTopLimit
                            ::_decrement(N_ROW_GET)
                            lRefresh := .T.
                        ENDIF
                    ENDIF

                    IF nMouseCol > ::_get_value(N_COL_GET)
                        IF ::_get_value(N_COL_GET) <= nRightLimit
                            ::_increment(N_COL_GET)
                            lRefresh := .T.
                        ENDIF
                    ELSEIF nMouseCol < ::_get_value(N_COL_GET)
                        IF ::_get_value(N_COL_GET) >= nLeftLimit
                            ::_decrement(N_COL_GET)
                            lRefresh := .T.
                        ENDIF
                    ENDIF

                    IF lRefresh
                        ::__refresh_and_display(nTop, nLeft, nBottom, nRight, nOldWindow, xFormCode, xGetPos, @aoWasGetList, cScreen)
                    ELSE
                        ::_mouse_sleep()
                    ENDIF
                ENDDO
            CASE nKey == K_RBUTTONUP
                ::_display_menu(nTop, nLeft, nBottom, nRight, cScreen, xFormCode, xGetPos, NIL, @lFinish, @lSave)
            CASE nKey == K_ESC
                IF YesNo(Config():get_config('YesNoBreakEdition'))
                    IF YesNo(Config():get_config('YesNoSave'))
                        IF ::_save_form()
                            lFinish := .T.
                            lSave := .T.
                        ENDIF
                    ELSE 
                        lFinish := .T.
                    ENDIF
                ENDIF
        ENDCASE
    ENDDO

    Window():header(cOldHeader)
    Window():footer(cOldFooter)
    Window():refresh_header_footer()

RETURN lSave
