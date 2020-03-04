#include "hbclass.ch"
#include "inkey.ch"

#include "rowbrowse.ch"
#include "functions.ch"

#include "creator.ch"
#include "variables.ch"

#define LISTBOX_SLOT 11
#define TOP_POSITION Window():get_top() + 2
#define LEFT_POSITION Window():get_left() + 2
#define BOTTOM_POSITION Window():get_bottom() - 2
#define RIGHT_POSITION Window():get_right() - 2

#define LISTBOX_ELEMENTS {'1', '2', '3', '4'}

CLASS Creator MODULE FRIENDLY

EXPORTED:

    METHOD edit_form(xFormCode, xGetPos) VIRTUAL

PROTECTED:

    METHOD form_fast_edit(nTop, nLeft, nBottom, nRight, cScreen, xFormCode, xGetPos) 
    METHOD display_form()
    METHOD make_form_array(xCode)
    METHOD save_form()
    METHOD increment(nVariable) INLINE ++Creator():aoVariables[nVariable]
    METHOD decrement(nVariable) INLINE --Creator():aoVariables[nVariable]
    METHOD set_type(cType) INLINE Creator():cType := cType
    METHOD get_value(nIndex) INLINE Creator():aoVariables[nIndex]:get_value()
    METHOD set_value(nIndex, xValue) INLINE Creator():aoVariables[nIndex]:set_value(xValue)
    METHOD clear_window_flag() INLINE Creator():lIsWindow := .F.
    METHOD set_distinct_name(cName, hJson, lAcceptFirstOption)

    METHOD is_variable(acForm, nIndex) INLINE SubStr(acForm[nIndex], 1, 1) == VARIABLE 
    METHOD extract_type(acForm, nIndex) INLINE SubStr(acForm[nIndex], 2, 1)
    METHOD extract_value(acForm, nIndex, hJson) INLINE IF(::is_variable(acForm, nIndex), hJson[::extract_name(acForm, nIndex)], cast(SubStr(acForm[nIndex], 3), ::extract_type(acForm, nIndex)))
    METHOD extract_name(acForm, nIndex) INLINE RTrim(SubStr(acForm[nIndex], 3))

    METHOD create_window_form_shadow(acForm, nIndex, hJson)
    METHOD create_say_get_form_expression(acForm, nIndex, hJson)
    METHOD create_get_form_variable(acForm, nIndex, hJson)
    METHOD create_listbox_radiogroup_form_variable(acForm, nIndex, hJson)

    METHOD validate_listbox_list(xList)
    METHOD validate_radiogroup_group(xGroup)

HIDDEN:

    CLASSVAR aoVariables AS ARRAY INIT Array(0)
    CLASSVAR cType AS CHARACTER INIT ''
    CLASSVAR lIsWindow AS LOGICAL INIT .F.

ENDCLASS LOCK 

METHOD make_form_array(xCode) CLASS Creator

    LOCAL hJson := hb_JsonDecode(dbVariables->json)
    LOCAL acForm

    IF ValType(hJson) != 'H'
        hJson := hb_Hash()
    ENDIF

    IF PCount() == 0 .OR. ValType(xCode) != 'A'
        DO CASE
            CASE Creator():cType == OBJECT_WINDOW
                Creator():aoVariables := {Variable():new('Top';
                                                        , .F.;
                                                        , {TOP_POSITION};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= Window():get_top() .AND. Val(oGet:buffer) <= Window():get_bottom()}};
                                                        );
                                        , Variable():new('Left';
                                                        , .F.;
                                                        , {LEFT_POSITION};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= Window():get_left()  .AND. Val(oGet:buffer) <= Window():get_right()}};
                                                        );
                                        , Variable():new('Bottom';
                                                        , .F.;
                                                        , {BOTTOM_POSITION};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= Window():get_top() .AND. Val(oGet:buffer) <= Window():get_bottom()}};
                                                        );
                                        , Variable():new('Right';
                                                        , .F.;
                                                        , {RIGHT_POSITION};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= Window():get_left() .AND. Val(oGet:buffer) <= Window():get_right()}};
                                                        );
                                        , Variable():new('Box';
                                                        , .F.;
                                                        , {Config():get_config('DefaultWindowCreatorBox')};
                                                        , {'C'};
                                                        , {{| oGet | is_box(AllTrim(oGet:buffer))}};
                                                        );
                                        , Variable():new('Color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultWindowCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                         , Variable():new('Shadow';
                                                        , .F.;
                                                        , {Config():get_config('DefaultWindowCreatorShadow'), -1};
                                                        , {'C', 'N'};
                                                        , {{| oGet | AScan({'N', 'B', 'G', 'BG', 'R', 'RB', 'GR', 'W', 'N+', 'B+', 'G+', 'BG+', 'R+', 'RB+', 'GR+', 'W+'}, oGet:buffer) > 0 }, {| oGet | Val(oGet:buffer) == -1}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_BOX
                Creator():aoVariables := {Variable():new('Top';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, TOP_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Left';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, LEFT_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0)  .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new('Bottom';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, BOTTOM_POSITION, MaxRow())};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Right';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, RIGHT_POSITION, MaxCol())};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new('Box';
                                                        , .F.;
                                                        , {Config():get_config('DefaultBoxCreatorBox')};
                                                        , {'C'};
                                                        , {{| oGet | is_box(AllTrim(oGet:buffer))}};
                                                        );
                                        , Variable():new('Color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultBoxCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_SAY 
                Creator():aoVariables := {Variable():new('Row';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, TOP_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Column';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, LEFT_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new('Expression';
                                                        , .F.;
                                                        , {'Expression', 3.14, Date(), .T.};
                                                        , {'C', 'N', 'D', 'L'};
                                                        , {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}};
                                                        );
                                        , Variable():new('Picture';
                                                        , .F.;
                                                        , {'@! AAAAAAAAAA'};
                                                        , {'C'};
                                                        , {{| oGet | is_picture(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultSayCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_GET
                Creator():aoVariables := {Variable():new('Row';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, TOP_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Column';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, LEFT_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new('Expression';
                                                        , .F.;
                                                        , {'Expression', 3.14, Date(), .T.};
                                                        , {'C', 'N', 'D', 'L'};
                                                        , {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}};
                                                        );
                                        , Variable():new('Say picture';
                                                        , .F.;
                                                        , {'@! AAAAAAAAAA'};
                                                        , {'C'};
                                                        , {{| oGet | is_picture(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Say color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultGetSayCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        , Variable():new(::set_distinct_name('Variable', hJson);
                                                        , .T.;
                                                        , {'Variable', 2.78, d"1991-01-01", .F.};
                                                        , {'C', 'N', 'D', 'L'};
                                                        , {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}};
                                                        );
                                        , Variable():new('Get picture';
                                                        , .F.;
                                                        , {'@! AAAAAAAAAA'};
                                                        , {'C'};
                                                        , {{| oGet | is_picture(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Get color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultGetGetCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Caption';
                                                        , .F.;
                                                        , {'Caption'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Message';
                                                        , .F.;
                                                        , {'Message'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('When';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Valid';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_CHECKBOX
                Creator():aoVariables := {Variable():new('Row';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, TOP_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Column';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, LEFT_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(::set_distinct_name('Variable', hJson);
                                                        , .T.;
                                                        , {.F.};
                                                        , {'L'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Caption';
                                                        , .F.;
                                                        , {'Caption'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Message';
                                                        , .F.;
                                                        , {'Message'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('When';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Valid';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultCheckboxCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.) .AND. !Empty(hb_ColorIndex(AllTrim(oGet:buffer), 3)) .AND. Empty(hb_ColorIndex(AllTrim(oGet:buffer), 4))}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Focus';
                                                        , .F.;
                                                        , {'True()'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('State';
                                                        , .F.;
                                                        , {'True()'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Style';
                                                        , .F.;
                                                        , {'[X ]'};
                                                        , {'C'};
                                                        , {{| oGet | is_checkbox_style(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_LISTBOX
                       Creator():aoVariables := {Variable():new('Top';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, TOP_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Left';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, LEFT_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0)  .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new('Bottom';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, BOTTOM_POSITION, MaxRow())};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Right';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, RIGHT_POSITION, MaxCol())};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(::set_distinct_name('Variable', hJson);
                                                        , .T.;
                                                        , {LISTBOX_ELEMENTS[2], 1};
                                                        , {'C', 'N'};
                                                        , {{|| .T.}, {|| .T.}};
                                                        );
                                        , Variable():new('List';
                                                        , .F.;
                                                        , {LISTBOX_ELEMENTS};
                                                        , {'A'};
                                                        , {{| xValue | ::validate_listbox_list(xValue)}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Caption';
                                                        , .F.;
                                                        , {'Caption'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Message';
                                                        , .F.;
                                                        , {'Message'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('When';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Valid';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultListboxCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.) .AND. IF(Creator_listbox():dropdown(), !Empty(hb_ColorIndex(AllTrim(oGet:buffer), 7)) .AND. Empty(hb_ColorIndex(AllTrim(oGet:buffer), 8)), !Empty(hb_ColorIndex(AllTrim(oGet:buffer), 6)) .AND. Empty(hb_ColorIndex(AllTrim(oGet:buffer), 7)))}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Focus';
                                                        , .F.;
                                                        , {'True()'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('State';
                                                        , .F.;
                                                        , {'True()'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Dropdown';
                                                        , .F.;
                                                        , {.F.};
                                                        , {'L'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Scrollbar';
                                                        , .F.;
                                                        , {.T.};
                                                        , {'L'};
                                                        , {{|| .T.}};
                                                        );
                                        }
            CASE Creator():cType == OBJECT_RADIOGROUP
                       Creator():aoVariables := {Variable():new('Top';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, TOP_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Left';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, LEFT_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0)  .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new('Bottom';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, BOTTOM_POSITION, MaxRow())};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Right';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, RIGHT_POSITION, MaxCol())};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(::set_distinct_name('Variable', hJson);
                                                        , .T.;
                                                        , {'Variable', 1};
                                                        , {'C', 'N'};
                                                        , {{|| .T.}, {|| .T.}};
                                                        );
                                        , Variable():new('Group';
                                                        , .F.;
                                                        , {{'3,20,&Guzik,G', '4,15,Atam&guzik,A'}};
                                                        , {'A'};
                                                        , {{| xValue | ::validate_radiogroup_group(xValue)}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Caption';
                                                        , .F.;
                                                        , {'Caption'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Message';
                                                        , .F.;
                                                        , {'Message'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultRadiogroupCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.) .AND. !Empty(hb_ColorIndex(AllTrim(oGet:buffer), 2)) .AND. Empty(hb_ColorIndex(AllTrim(oGet:buffer), 3))}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Focus';
                                                        , .F.;
                                                        , {'True()'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('When';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Valid';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_PUSHBUTTON
                Creator():aoVariables := {Variable():new('Row';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, TOP_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new('Column';
                                                        , .F.;
                                                        , {IF(WSelect() == 0, LEFT_POSITION, 0)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(::set_distinct_name('Variable', hJson);
                                                        , .T.;
                                                        , {.F.};
                                                        , {'L'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Caption';
                                                        , .F.;
                                                        , {'Caption'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('Message';
                                                        , .F.;
                                                        , {'Message'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new('When';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Valid';
                                                        , .F.;
                                                        , {'{|| True()}'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Color';
                                                        , .F.;
                                                        , {Config():get_config('DefaultPushbuttonCreatorColor')};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Focus';
                                                        , .F.;
                                                        , {'True()'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('State';
                                                        , .F.;
                                                        , {'True()'};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new('Style';
                                                        , .F.;
                                                        , {'[]'};
                                                        , {'C'};
                                                        , {{| oGet | is_pushbutton_style(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        }
            OTHERWISE
                throw(RUNTIME_EXCEPTION)
        ENDCASE
    ELSE
        acForm := hb_ATokens(xCode[field->line_nr], LINE_SEPARATOR)

        DO CASE
            CASE Creator():cType == OBJECT_WINDOW
                Creator():aoVariables := {Variable():new(IF(::is_variable(acForm, 2), ::extract_name(acForm, 2), 'Top');
                                                        , ::is_variable(acForm, 2);
                                                        , {::extract_value(acForm, 2, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= Window():get_top() .AND. Val(oGet:buffer) <= Window():get_bottom()}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 3), ::extract_name(acForm, 3), 'Left');
                                                        , ::is_variable(acForm, 3);
                                                        , {::extract_value(acForm, 3, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= Window():get_left()  .AND. Val(oGet:buffer) <= Window():get_right()}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 4), ::extract_name(acForm, 4), 'Bottom');
                                                        , ::is_variable(acForm, 4);
                                                        , {::extract_value(acForm, 4, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= Window():get_top() .AND. Val(oGet:buffer) <= Window():get_bottom()}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 5), ::extract_name(acForm, 5), 'Right');
                                                        , ::is_variable(acForm, 5);
                                                        , {::extract_value(acForm, 5, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= Window():get_left() .AND. Val(oGet:buffer) <= Window():get_right()}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 6), ::extract_name(acForm, 6), 'Box');
                                                        , ::is_variable(acForm, 6);
                                                        , {::extract_value(acForm, 6, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_box(AllTrim(oGet:buffer))}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 7), ::extract_name(acForm, 7), 'Color');
                                                        , ::is_variable(acForm, 7);
                                                        , {::extract_value(acForm, 7, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                         , ::create_window_form_shadow(acForm, 8, hJson);
                                        }
            CASE Creator():cType == OBJECT_BOX
                Creator():aoVariables := {Variable():new(IF(::is_variable(acForm, 2), ::extract_name(acForm, 2), 'Top');
                                                        , ::is_variable(acForm, 2);
                                                        , {::extract_value(acForm, 2, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 3), ::extract_name(acForm, 3), 'Left');
                                                        , ::is_variable(acForm, 3);
                                                        , {::extract_value(acForm, 3, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0)  .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 4), ::extract_name(acForm, 4), 'Bottom');
                                                        , ::is_variable(acForm, 4);
                                                        , {::extract_value(acForm, 4, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 5), ::extract_name(acForm, 5), 'Right');
                                                        , ::is_variable(acForm, 5);
                                                        , {::extract_value(acForm, 5, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 6), ::extract_name(acForm, 6), 'Box');
                                                        , ::is_variable(acForm, 6);
                                                        , {::extract_value(acForm, 6, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_box(AllTrim(oGet:buffer))}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 7), ::extract_name(acForm, 7), 'Color');
                                                        , ::is_variable(acForm, 7);
                                                        , {::extract_value(acForm, 7, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_SAY 
                Creator():aoVariables := {Variable():new(IF(::is_variable(acForm, 2), ::extract_name(acForm, 2), 'Row');
                                                        , ::is_variable(acForm, 2);
                                                        , {::extract_value(acForm, 2, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 3), ::extract_name(acForm, 3), 'Column');
                                                        , ::is_variable(acForm, 3);
                                                        , {::extract_value(acForm, 3, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , ::create_say_get_form_expression(acForm, 4, hJson);
                                        , Variable():new(IF(::is_variable(acForm, 5), ::extract_name(acForm, 5), 'Picture');
                                                        , ::is_variable(acForm, 5);
                                                        , {::extract_value(acForm, 5, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_picture(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 6), ::extract_name(acForm, 6), 'Color');
                                                        , ::is_variable(acForm, 6);
                                                        , {::extract_value(acForm, 6, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_GET

                Creator():aoVariables := {Variable():new(IF(::is_variable(acForm, 2), ::extract_name(acForm, 2), 'Row');
                                                        , ::is_variable(acForm, 2);
                                                        , {::extract_value(acForm, 2, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 3), ::extract_name(acForm, 3), 'Column');
                                                        , ::is_variable(acForm, 3);
                                                        , {::extract_value(acForm, 3, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , ::create_say_get_form_expression(acForm, 4, hJson);
                                        , Variable():new(IF(::is_variable(acForm, 5), ::extract_name(acForm, 5), 'Say picture');
                                                        , ::is_variable(acForm, 5);
                                                        , {::extract_value(acForm, 5, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_picture(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 6), ::extract_name(acForm, 6), 'Say color');
                                                        , ::is_variable(acForm, 6);
                                                        , {::extract_value(acForm, 6, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        , ::create_get_form_variable(acForm, 7, hJson);
                                        , Variable():new(IF(::is_variable(acForm, 8), ::extract_name(acForm, 8), 'Get picture');
                                                        , ::is_variable(acForm, 8);
                                                        , {::extract_value(acForm, 8, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_picture(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 9), ::extract_name(acForm, 9), 'Get color');
                                                        , ::is_variable(acForm, 9);
                                                        , {::extract_value(acForm, 9, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 10), ::extract_name(acForm, 10), 'Caption');
                                                        , ::is_variable(acForm, 10);
                                                        , {::extract_value(acForm, 10, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 11), ::extract_name(acForm, 11), 'Message');
                                                        , ::is_variable(acForm, 11);
                                                        , {::extract_value(acForm, 11, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 12), ::extract_name(acForm, 12), 'When');
                                                        , ::is_variable(acForm, 12);
                                                        , {::extract_value(acForm, 12, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 13), ::extract_name(acForm, 13), 'Valid');
                                                        , ::is_variable(acForm, 13);
                                                        , {::extract_value(acForm, 13, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_CHECKBOX
                Creator():aoVariables := {Variable():new(IF(::is_variable(acForm, 2), ::extract_name(acForm, 2), 'Row');
                                                        , ::is_variable(acForm, 2);
                                                        , {::extract_value(acForm, 2, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 3), ::extract_name(acForm, 3), 'Column');
                                                        , ::is_variable(acForm, 3);
                                                        , {::extract_value(acForm, 3, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(::extract_name(acForm, 4);
                                                        , .T.;
                                                        , {::extract_value(acForm, 4, hJson)};
                                                        , {'L'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 5), ::extract_name(acForm, 5), 'Caption');
                                                        , ::is_variable(acForm, 5);
                                                        , {::extract_value(acForm, 5, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 6), ::extract_name(acForm, 6), 'Message');
                                                        , ::is_variable(acForm, 6);
                                                        , {::extract_value(acForm, 6, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 7), ::extract_name(acForm, 7), 'When');
                                                        , ::is_variable(acForm, 7);
                                                        , {::extract_value(acForm, 7, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 8), ::extract_name(acForm, 8), 'Valid');
                                                        , ::is_variable(acForm, 8);
                                                        , {::extract_value(acForm, 8, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 9), ::extract_name(acForm, 9), 'Color');
                                                        , ::is_variable(acForm, 9);
                                                        , {::extract_value(acForm, 9, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.) .AND. !Empty(hb_ColorIndex(AllTrim(oGet:buffer), 3)) .AND. Empty(hb_ColorIndex(AllTrim(oGet:buffer), 4))}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 10), ::extract_name(acForm, 10), 'Focus');
                                                        , ::is_variable(acForm, 10);
                                                        , {::extract_value(acForm, 10, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 11), ::extract_name(acForm, 11), 'State');
                                                        , ::is_variable(acForm, 11);
                                                        , {::extract_value(acForm, 11, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 12), ::extract_name(acForm, 12), 'Style');
                                                        , ::is_variable(acForm, 12);
                                                        , {::extract_value(acForm, 12, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_checkbox_style(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_LISTBOX
                       Creator():aoVariables := {Variable():new(IF(::is_variable(acForm, 2), ::extract_name(acForm, 2), 'Top');
                                                        , ::is_variable(acForm, 2);
                                                        , {::extract_value(acForm, 2, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 3), ::extract_name(acForm, 3), 'Left');
                                                        , ::is_variable(acForm, 3);
                                                        , {::extract_value(acForm, 3, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0)  .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 4), ::extract_name(acForm, 4), 'Bottom');
                                                        , ::is_variable(acForm, 4);
                                                        , {::extract_value(acForm, 4, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 5), ::extract_name(acForm, 5), 'Right');
                                                        , ::is_variable(acForm, 5);
                                                        , {::extract_value(acForm, 5, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , ::create_listbox_radiogroup_form_variable(acForm, 6, hJson);
                                        , Variable():new(IF(::is_variable(acForm, 7), ::extract_name(acForm, 7), 'List');
                                                        , ::is_variable(acForm, 7);
                                                        , {hb_JsonDecode(IF(::is_variable(acForm, 7), hJson[::extract_name(acForm, 7)], RTrim(SubStr(acForm[7], 3))))['']};
                                                        , {'A'};
                                                        , {{| xValue | ::validate_listbox_list(xValue)}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 8), ::extract_name(acForm, 8), 'Caption');
                                                        , ::is_variable(acForm, 8);
                                                        , {::extract_value(acForm, 8, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 9), ::extract_name(acForm, 9), 'Message');
                                                        , ::is_variable(acForm, 9);
                                                        , {::extract_value(acForm, 9, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 10), ::extract_name(acForm, 10), 'When');
                                                        , ::is_variable(acForm, 10);
                                                        , {::extract_value(acForm, 10, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 11), ::extract_name(acForm, 11), 'Valid');
                                                        , ::is_variable(acForm, 11);
                                                        , {::extract_value(acForm, 11, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 12), ::extract_name(acForm, 12), 'Color');
                                                        , ::is_variable(acForm, 12);
                                                        , {::extract_value(acForm, 12, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.) .AND. IF(Creator_listbox():dropdown(), !Empty(hb_ColorIndex(AllTrim(oGet:buffer), 7)) .AND. Empty(hb_ColorIndex(AllTrim(oGet:buffer), 8)), !Empty(hb_ColorIndex(AllTrim(oGet:buffer), 6)) .AND. Empty(hb_ColorIndex(AllTrim(oGet:buffer), 7)))}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 13), ::extract_name(acForm, 13), 'Focus');
                                                        , ::is_variable(acForm, 13);
                                                        , {::extract_value(acForm, 13, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 14), ::extract_name(acForm, 14), 'State');
                                                        , ::is_variable(acForm, 14);
                                                        , {::extract_value(acForm, 14, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 15), ::extract_name(acForm, 15), 'Dropdown');
                                                        , ::is_variable(acForm, 15);
                                                        , {::extract_value(acForm, 15, hJson)};
                                                        , {'L'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 16), ::extract_name(acForm, 16), 'Scrollbar');
                                                        , ::is_variable(acForm, 16);
                                                        , {::extract_value(acForm, 16, hJson)};
                                                        , {'L'};
                                                        , {{|| .T.}};
                                                        );
                                        }
            CASE Creator():cType == OBJECT_RADIOGROUP
                       Creator():aoVariables := {Variable():new(IF(::is_variable(acForm, 2), ::extract_name(acForm, 2), 'Top');
                                                        , ::is_variable(acForm, 2);
                                                        , {::extract_value(acForm, 2, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 3), ::extract_name(acForm, 3), 'Left');
                                                        , ::is_variable(acForm, 3);
                                                        , {::extract_value(acForm, 3, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0)  .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 4), ::extract_name(acForm, 4), 'Bottom');
                                                        , ::is_variable(acForm, 4);
                                                        , {::extract_value(acForm, 4, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 5), ::extract_name(acForm, 5), 'Right');
                                                        , ::is_variable(acForm, 5);
                                                        , {::extract_value(acForm, 5, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , ::create_listbox_radiogroup_form_variable(acForm, 6, hJson);
                                        , Variable():new(IF(::is_variable(acForm, 7), ::extract_name(acForm, 7), 'Group');
                                                        , ::is_variable(acForm, 7);
                                                        , {hb_JsonDecode(IF(::is_variable(acForm, 7), hJson[::extract_name(acForm, 7)], RTrim(SubStr(acForm[7], 3))))['']};
                                                        , {'A'};
                                                        , {{| xValue | ::validate_radiogroup_group(xValue)}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 8), ::extract_name(acForm, 8), 'Caption');
                                                        , ::is_variable(acForm, 8);
                                                        , {::extract_value(acForm, 8, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 9), ::extract_name(acForm, 9), 'Message');
                                                        , ::is_variable(acForm, 9);
                                                        , {::extract_value(acForm, 9, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 10), ::extract_name(acForm, 10), 'Color');
                                                        , ::is_variable(acForm, 10);
                                                        , {::extract_value(acForm, 10, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.) .AND. !Empty(hb_ColorIndex(AllTrim(oGet:buffer), 2)) .AND. Empty(hb_ColorIndex(AllTrim(oGet:buffer), 3))}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 11), ::extract_name(acForm, 11), 'Focus');
                                                        , ::is_variable(acForm, 11);
                                                        , {::extract_value(acForm, 11, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 12), ::extract_name(acForm, 12), 'When');
                                                        , ::is_variable(acForm, 12);
                                                        , {::extract_value(acForm, 12, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 13), ::extract_name(acForm, 13), 'Valid');
                                                        , ::is_variable(acForm, 13);
                                                        , {::extract_value(acForm, 13, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        }
            CASE Creator():cType == OBJECT_PUSHBUTTON
                Creator():aoVariables := {Variable():new(IF(::is_variable(acForm, 2), ::extract_name(acForm, 2), 'Row');
                                                        , ::is_variable(acForm, 2);
                                                        , {::extract_value(acForm, 2, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_top(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_bottom(), MaxRow())}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 3), ::extract_name(acForm, 3), 'Column');
                                                        , ::is_variable(acForm, 3);
                                                        , {::extract_value(acForm, 3, hJson)};
                                                        , {'N'};
                                                        , {{| oGet | Val(oGet:buffer) >= IF(WSelect() == 0, Window():get_left(), 0) .AND. Val(oGet:buffer) <= IF(WSelect() == 0, Window():get_right(), MaxCol())}};
                                                        );
                                        , Variable():new(::extract_name(acForm, 4);
                                                        , .T.;
                                                        , {::extract_value(acForm, 4, hJson)};
                                                        , {'L'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 5), ::extract_name(acForm, 5), 'Caption');
                                                        , ::is_variable(acForm, 5);
                                                        , {::extract_value(acForm, 5, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 6), ::extract_name(acForm, 6), 'Message');
                                                        , ::is_variable(acForm, 6);
                                                        , {::extract_value(acForm, 6, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 7), ::extract_name(acForm, 7), 'When');
                                                        , ::is_variable(acForm, 7);
                                                        , {::extract_value(acForm, 7, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 8), ::extract_name(acForm, 8), 'Valid');
                                                        , ::is_variable(acForm, 8);
                                                        , {::extract_value(acForm, 8, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 9), ::extract_name(acForm, 9), 'Color');
                                                        , ::is_variable(acForm, 9);
                                                        , {::extract_value(acForm, 9, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_color(oGet:buffer, .T.)}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 10), ::extract_name(acForm, 10), 'Focus');
                                                        , ::is_variable(acForm, 10);
                                                        , {::extract_value(acForm, 10, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 11), ::extract_name(acForm, 11), 'State');
                                                        , ::is_variable(acForm, 11);
                                                        , {::extract_value(acForm, 11, hJson)};
                                                        , {'C'};
                                                        , {{|| .T.}};
                                                        , .T.;
                                                        );
                                        , Variable():new(IF(::is_variable(acForm, 12), ::extract_name(acForm, 12), 'Style');
                                                        , ::is_variable(acForm, 12);
                                                        , {::extract_value(acForm, 12, hJson)};
                                                        , {'C'};
                                                        , {{| oGet | is_pushbutton_style(RTrim(oGet:buffer))}};
                                                        , .T.;
                                                        );
                                        }
            OTHERWISE
                throw(RUNTIME_EXCEPTION)
        ENDCASE
    ENDIF

RETURN NIL

METHOD create_say_get_form_expression(acForm, nIndex, hJson) CLASS Creator

    LOCAL cType := ::extract_type(acForm, nIndex)
    LOCAL lIsVariable := ::is_variable(acForm, nIndex)
    LOCAL cName := IF(lIsVariable, ::extract_name(acForm, nIndex), 'Expression')
    LOCAL oResult

    DO CASE
        CASE cType == 'C'
            oResult := Variable():new(cName, ::is_variable(acForm, nIndex), {::extract_value(acForm, nIndex, hJson), 3.14, Date(), .T.};
                                      , {'C', 'N', 'D', 'L'}, {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}};
                                     )
        CASE cType == 'N'
            oResult := Variable():new(cName, ::is_variable(acForm, nIndex), {'Expression', ::extract_value(acForm, nIndex, hJson), Date(), .T.};
                                      , {'C', 'N', 'D', 'L'}, {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}};
                                     )
        CASE cType == 'D'
            oResult := Variable():new(cName, ::is_variable(acForm, nIndex), {'Expression',  3.14, ::extract_value(acForm, nIndex, hJson), .T.};
                                      , {'C', 'N', 'D', 'L'}, {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}};
                                     )
        CASE cType == 'L'
            oResult := Variable():new(cName, ::is_variable(acForm, nIndex), {'Expression',  3.14, Date(), ::extract_value(acForm, nIndex, hJson)};
                                      , {'C', 'N', 'D', 'L'}, {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}};
                                     )
    ENDCASE

RETURN oResult

METHOD create_get_form_variable(acForm, nIndex, hJson) CLASS Creator

    LOCAL cType := ::extract_type(acForm, nIndex)
    LOCAL cName := ::extract_name(acForm, nIndex, hJson)
    LOCAL oResult

    DO CASE
        CASE cType == 'C'
            oResult := Variable():new(cName, .T., {hJson[cName], 3.14, Date(), .T.};
                                      , {'C', 'N', 'D', 'L'}, {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}}, , 1;
                                     )
        CASE cType == 'N'
            oResult := Variable():new(cName, .T., {'Expression', hJson[cName], Date(), .T.};
                                      , {'C', 'N', 'D', 'L'}, {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}}, , 2;
                                     )
        CASE cType == 'D'
            oResult := Variable():new(cName, .T., {'Expression',  3.14, hJson[cName], .T.};
                                      , {'C', 'N', 'D', 'L'}, {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}}, , 3;
                                     )
        CASE cType == 'L'
            oResult := Variable():new(cName, .T., {'Expression',  3.14, Date(), hJson[cName]};
                                      , {'C', 'N', 'D', 'L'}, {{|| .T.}, {|| .T.}, {|| .T.}, {|| .T.}}, , 4;
                                     )
    ENDCASE

RETURN oResult

METHOD create_listbox_radiogroup_form_variable(acForm, nIndex, hJson) CLASS Creator

    LOCAL cType := ::extract_type(acForm, nIndex)
    LOCAL cName := ::extract_name(acForm, nIndex)
    LOCAL oResult

    DO CASE
        CASE cType == 'C'
            oResult := Variable():new(cName, .T., {hJson[cName], 1}, {'C', 'N'}, {{|| .T.}, {|| .T.}}, , 1)
        CASE cType == 'N'
            oResult := Variable():new(cName, .T., {'Variable', hJson[cName]}, {'C', 'N'}, {{|| .T.}, {|| .T.}}, , 2)
    ENDCASE

RETURN oResult

METHOD create_window_form_shadow(acForm, nIndex, hJson) CLASS Creator

    LOCAL cType := ::extract_type(acForm, nIndex)
    LOCAL lIsVariable := ::is_variable(acForm, nIndex)
    LOCAL cName := IF(lIsVariable, ::extract_name(acForm, nIndex), 'Shadow')
    LOCAL oResult

    DO CASE
        CASE cType == 'C'
            oResult := Variable():new(cName, lIsVariable, {::extract_value(acForm, nIndex, hJson), -1};
                                      , {'C', 'N'}, {{|| .T.}, {|| .T.}}, , 1;
                                     )
        CASE cType == 'N'
            oResult := Variable():new(cName, lIsVariable, {Config():get_config('DefaultWindowCreatorShadow'), ::extract_value(acForm, nIndex, hJson)};
                                      , {'C', 'N'}, {{|| .T.}, {|| .T.}};
                                     )
    ENDCASE

RETURN oResult

METHOD set_distinct_name(cName, hJson, lAcceptFirstOption) CLASS Creator

    MEMVAR GETLIST

    LOCAL nOldWindow := WSelect()
    LOCAL nOldRecNo := dbForms->(RecNo())
    LOCAL aoOldGetList := AClone(GETLIST)
    LOCAL hVariables := hb_Hash('Variable', cName + Space(VARIABLE_CHARACTER_LENGTH - Len(cName)))
    LOCAL cFirstOption := cName
    LOCAL cOldScreen

    hb_Default(@lAcceptFirstOption, .F.)

    CLEAR GETS

    IF YesNo(Config():get_config('ChangeVariableName') + ';' + cName)
        WSelect(0)
        SAVE SCREEN TO cOldScreen
        IF Parser():prepare_form_from_database(Config():get_config('Language'), 'SET_DISTINCT_NAME', hVariables)
            READ
            hVariables := Parser():get_answers()
            cName := AllTrim(hVariables['Variable'])
            WClose()
            WSelect(0)
            RESTORE SCREEN FROM cOldScreen
        ELSE
            throw(Config():get_config('CriticalError'))
        ENDIF
    ENDIF

    DO WHILE hb_HHasKey(hJson, cName)

        IF lAcceptFirstOption .AND. cName == cFirstOption
            EXIT
        ENDIF

        Inform(Config():get_config('DistinctNameFirstPart') + AllTrim(cName) + Config():get_config('DistinctNameSecondPart'))
        hVariables := hb_Hash('Variable', cName + Space(VARIABLE_CHARACTER_LENGTH - Len(cName)))
        WSelect(0)
        IF Parser():prepare_form_from_database(Config():get_config('Language'), 'SET_DISTINCT_NAME', hVariables)
            READ
            hVariables := Parser():get_answers()
            cName := AllTrim(hVariables['Variable'])
            WClose()
            WSelect(0)
            RESTORE SCREEN FROM cOldScreen
        ELSE
            throw(Config():get_config('CriticalError'))
        ENDIF
    ENDDO

    GETLIST := aoOldGetList
    WSelect(nOldWindow)
    dbForms->(dbGoTo(nOldRecNo))

RETURN cName

METHOD save_form() CLASS Creator

    MEMVAR GETLIST

    LOCAL aoOldGetList := AClone(GETLIST)
    LOCAL nOldWindow := WSelect()
    LOCAL nOldShadow := WSetShadow(-1)
    LOCAL nOldSelect := Select()
    LOCAL cOldFooter := Window():footer(Config():get_config('SaveFooter'))
    LOCAL cOldHeader := Window():header(Config():get_config('SaveHeader'))
    LOCAL cVariable := Config():get_config('SaveAsVariable')
    LOCAL cString := Creator():cType + LINE_SEPARATOR
    LOCAL axStructure := {;
                            {'begin_name', 'C', 20, 0}; 
                            , {'name', 'C', 20, 0};
                            , {'value', 'C', 20, 0};
                            , {'method', 'C', 8, 0};
                            , {'is_ID', 'L', 1, 0};
                         } 
    LOCAL nRowLength := 73
    LOCAL nTop := Window():center_row() - Int(Len(Creator():aoVariables) / 2)
    LOCAL nLeft := Window():center_col() - Int(nRowLength / 2)
    LOCAL lEnd := .F.
    LOCAL nAction
    LOCAL oRowBrowse
    LOCAL oElement
    LOCAL hJson
    LOCAL cOldScreen
    LOCAL axOldKeys

    SAVE SCREEN TO cOldScreen
    ZAP KEYS TO axOldKeys

    GETLIST := {}
    WSelect(0)

    hJson := hb_JsonDecode(dbVariables->json)

    IF ValType(hJson) != 'H'
        hJson := hb_Hash()
    ENDIF

    dbCreate('mem:dbSave', axStructure, hb_Memio(), .T., 'dbSave')

    FOR EACH oElement IN Creator():aoVariables
        APPEND BLANK
        field->name := oElement:get_name()
        IF ValType(oElement:get_value()) != 'A'
            field->value := AllTrim(cast(oElement:get_value(), 'C'))
        ELSE
            field->value := hb_JsonEncode(oElement:get_value(), .T.)
        ENDIF
        field->is_ID := oElement:is_variable_id()

        IF field->is_ID
            field->begin_name := 'Variable'
            field->method := Config():get_config('SaveAsVariable')
            field->name := ::set_distinct_name(oElement:get_name(), hJson, Select('DBREORDER') != 0) 
            hJson[RTrim(field->name)] := oElement:get_value()
        ELSE
            field->begin_name := oElement:get_name()
            field->method := Config():get_config('SaveAsConstant')
        ENDIF
    NEXT

    GO TOP

    WOpen(nTop, nLeft, nTop + Len(Creator():aoVariables), Window():center_col() + Int(nRowLength / 2))

    @ 0, 0, MaxRow(), MaxCol() ROWBROWSE oRowBrowse ID 'save';
      COLOR Config():get_config('SaveColor') BORDER Config():get_config('RowBrowseDefaultBox') TITLE Config():get_config('SaveTitle');
      CARGO {hJson, Creator():aoVariables} ACTION {| oRowBrowse, nKey | row_browse_save(oRowBrowse, nKey)};
      COLORBLOCK {|| IF(field->is_ID, {3, 4}, {1, 2})} 

    DO WHILE !lEnd
        oRowBrowse:display()

        nAction := Dialog(Config():get_config('DialogWhatShouldIDo'), {Config():get_config('Continue'), Config():get_config('Save'), Config():get_config('Quit')})
        
        IF nAction != 1
            lEnd := .T.
        ENDIF
    ENDDO

    WClose()

    IF nAction == 2

        GO TOP
        DO WHILE !EoF()
            IF field->method == cVariable
                cString += Creator():aoVariables[RecNo()]:to_string(.T., field->name)
            ELSE
                cString += Creator():aoVariables[RecNo()]:to_string(.F.)
            ENDIF

            cString += LINE_SEPARATOR

            SKIP
        ENDDO

        IF Alias(nOldSelect) == 'DBREORDER'
            dbReorder->code := Left(cString, Len(cString) - 1)
        ELSE
            dbForms->code += IF(Empty(dbForms->code), '', OBJECT_SEPARATOR) + Left(cString, Len(cString) - 1)
        ENDIF

        dbVariables->json := hb_JsonEncode(hJson, .T.)

        COMMIT
    ENDIF

    CLOSE
    dbDrop('mem:dbSave')
    SELECT (nOldSelect)
    Window():header(cOldHeader)
    Window():footer(cOldFooter)
    WSelect(nOldWindow)
    WSetShadow(NToColor(nOldShadow))
    RESTORE SCREEN FROM cOldScreen
    RESTORE KEYS FROM axOldKeys
    GETLIST := aoOldGetList

RETURN nAction == 2

METHOD display_form() CLASS Creator

    LOCAL cString := Creator():cType + LINE_SEPARATOR
    LOCAL hJson
    LOCAL cName
    LOCAL oElement
    LOCAL lSuccess

    hJson := hb_JsonDecode(dbVariables->json)

    IF ValType(hJson) != 'H'
        hJson := hb_Hash()
    ENDIF

    FOR EACH oElement IN Creator():aoVariables
        IF oElement:is_variable_id()
            cName := oElement:get_name()

            IF Alias() != 'DBREORDER'
                DO WHILE hb_HHasKey(hJson, cName)
                    cName += Str(hb_RandomInt(0, 10))
                ENDDO
            ENDIF

            cString += oElement:to_string(.T.)
            hJson[cName] := oElement:get_value()
        ELSE
            cString += oElement:to_string(.F.)
        ENDIF

        cString += LINE_SEPARATOR
    NEXT

    cString := Left(cString, Len(cString) - 1)

    IF Creator():cType == OBJECT_WINDOW
        IF ::lIsWindow
            WClose()
        ELSE
            ::lIsWindow := .T.
        ENDIF
    ENDIF

    lSuccess := Parser():prepare_form_from_record(hb_ATokens(cString, OBJECT_SEPARATOR), hJson)

RETURN lSuccess

METHOD form_fast_edit(nTop, nLeft, nBottom, nRight, cScreen, xFormCode, xGetPos) CLASS Creator

    MEMVAR GETLIST

    LOCAL cOldHeader := Window():header(Config():get_config('FormFastEditHeader'))
    LOCAL cOldFooter := Window():footer(Config():get_config('MenuDefaultFooter'))
    LOCAL nOldWindow := WSelect()
    LOCAL aoWasVariables := clone_objects_array(Creator():aoVariables)
    LOCAL acMenuItems := Array(Len(Creator():aoVariables))
    LOCAL nChooseLoop := 1
    LOCAL lUpdated := .F.
    LOCAL lBrokenForm := .F.
    LOCAL lDisplayed
    LOCAL lWasDropdown
    LOCAL nChooseMenu
    LOCAL i

    WSelect(0)
    Window():refresh_header_footer()
    RestScreen(nTop, nLeft, nBottom, nRight, cScreen)
    WSelect(nOldWindow)
    WMove(WRow(), WCol())

    IF Alias() == 'DBREORDER'
        IF WSelect() > 0
            WClose()
        ENDIF

        prepare_form(ACopy(xFormCode, Array(field->line_nr - 1), 1, field->line_nr - 1))
        ::display_form()
        prepare_form(ACopy(xFormCode, Array(Len(xFormCode) - field->line_nr), field->line_nr + 1))
    ELSE
        ::display_form()
    ENDIF

    IF ::lIsWindow .AND. ValType(xFormCode) == 'A'
        prepare_form(xFormCode)
    ENDIF

    IF Creator():cType == OBJECT_LISTBOX .AND. Creator_listbox():dropdown()
        IF Alias() == 'DBREORDER'
            GETLIST[xGetPos][LISTBOX_SLOT]:open()
        ELSE
            GETLIST[Len(GETLIST)][LISTBOX_SLOT]:open()
        ENDIF

        lWasDropDown := Creator_listbox():dropdown()
    ENDIF

    GETLIST := ASize(GETLIST, Len(GETLIST) - 1)

    DO WHILE nChooseLoop == 1

        FOR i := 1 TO Len(Creator():aoVariables)
            acMenuItems[i] := Creator():aoVariables[i]:get_name()
        NEXT

        nChooseMenu := display_menu_center_autosize(Int(Window():center_row()), Int(Window():center_col()), acMenuItems, .T.;
                                               , 'menu_search_allow_exit_move', 1, Config():get_config('DefaultColor');
                                               , Config():get_config('DefaultBox');
                                               )

        IF nChooseMenu == 0
        
            IF lUpdated .AND. !lBrokenForm
                nChooseLoop := Dialog(Config():get_config('DialogWhatShouldIDo'), {Config():get_config('Continue'), Config():get_config('Save'), Config():get_config('Quit')})
                lBrokenForm := .F.
            ELSE
                nChooseLoop := IF(YesNo(Config():get_config('YesNoBreakEdition')), 0, 1)
            ENDIF
        ELSE
            lUpdated := Creator():aoVariables[nChooseMenu]:edit()

            IF Creator():cType == OBJECT_WINDOW
                WSelect(0)
                RestScreen(nTop, nLeft, nBottom, nRight, cScreen)
                WSelect(nOldWindow)
            ELSE
                WSelect(0)
                RestScreen(nTop, nLeft, nBottom, nRight, cScreen)
                WSelect(nOldWindow)
            ENDIF

            IF Creator():cType == OBJECT_LISTBOX
                IF Creator():aoVariables[L_DROPDOWN_LSB]:get_value()
                    Creator_listbox():dropdown(.T.)
                ELSE
                    Creator_listbox():dropdown(.F.)
                ENDIF
            ENDIF

            IF Alias() == 'DBREORDER'
                IF WSelect() > 0
                    WClose()
                ENDIF

                prepare_form(ACopy(xFormCode, Array(field->line_nr - 1), 1, field->line_nr - 1))
                lDisplayed := ::display_form()
                prepare_form(ACopy(xFormCode, Array(Len(xFormCode) - field->line_nr), field->line_nr + 1))
            ELSE
                lDisplayed := ::display_form()
            ENDIF

            IF lDisplayed

                IF ::lIsWindow .AND. ValType(xFormCode) == 'A'
                    prepare_form(xFormCode)
                ENDIF

                IF Creator():cType == OBJECT_LISTBOX .AND. Creator_listbox():dropdown()
                    IF Alias() == 'DBREORDER'
                        GETLIST[xGetPos][LISTBOX_SLOT]:open()
                    ELSE
                        GETLIST[Len(GETLIST)][LISTBOX_SLOT]:open()
                    ENDIF
                ENDIF

                GETLIST := ASize(GETLIST, Len(GETLIST) - 1)

                nChooseLoop := Dialog(Config():get_config('DialogWhatShouldIDo'), {Config():get_config('Continue'), Config():get_config('Save'), Config():get_config('Quit')})
                lBrokenForm := .F.
            ELSE
                Inform(Parser():log(''))
                nChooseLoop := Dialog(Config():get_config('BrokenFormWhatShouldIDo'), {Config():get_config('Continue'), Config():get_config('Quit')})
                lBrokenForm := .T.
            ENDIF
        ENDIF
    ENDDO

    IF (!lBrokenForm .AND. nChooseLoop == 3) .OR. (lBrokenForm .AND. nChooseLoop == 2) .OR. nChooseLoop == 0
        FOR i := 1 TO Len(Creator():aoVariables)
            Creator():aoVariables[i] := aoWasVariables[i]
        NEXT
        IF Creator():cType == OBJECT_LISTBOX
            Creator_listbox():dropdown(lWasDropdown)
        ENDIF
    ENDIF

    Window():header(cOldHeader)
    Window():footer(cOldFooter)
    Window():refresh_header_footer()
    WMove(WRow(), WCol())

RETURN NIL

METHOD validate_listbox_list(xList) CLASS Creator

    LOCAL xElement
    
    IF ValType(xList) != 'A'
        RETURN .F.
    ENDIF

    FOR EACH xElement IN xList
        IF ValType(xElement) != 'C'
            RETURN .F.
        ENDIF
    NEXT

RETURN .T.

METHOD validate_radiogroup_group(xGroup) CLASS Creator

    LOCAL xElement

    IF ValType(xGroup) != 'A'
        RETURN .F.
    ENDIF

    FOR EACH xElement IN xGroup
        IF ValType(xElement) != 'C'
            RETURN .F.
        ENDIF
    NEXT

RETURN .T.

FUNCTION row_browse_save(oRowBrowse, nKey)

    LOCAL cConstant := Config():get_config('SaveAsConstant')
    LOCAL cVariable := Config():get_config('SaveAsVariable')
    LOCAL hJson := oRowBrowse:cargo()[1]
    LOCAL aoVariables := oRowBrowse:cargo()[2]
    LOCAL cName

    DO CASE
        CASE nKey == K_SPACE
            IF field->is_id
                Inform(Config():get_config('ItIsVariable'))
            ELSEIF RTrim(field->method) == cConstant
                cName := Creator():set_distinct_name(aoVariables[RecNo()]:get_name(), hJson)

                field->method := cVariable
                field->name := cName

                hJson[cName] := aoVariables[RecNo()]:get_value()
                oRowBrowse:cargo({hJson, aoVariables})
            ELSE
                cName := RTrim(field->name)

                field->method := cConstant
                field->name := aoVariables[RecNo()]:get_name()

                IF hb_hHasKey(hJson, cName)
                    hb_hDel(hJson, cName)
                ENDIF
            ENDIF
        CASE nKey == K_ENTER
            IF RTrim(field->method) == cVariable

                hb_hDel(hJson, RTrim(field->name))

                cName := Creator():set_distinct_name(RTrim(field->name), hJson)

                field->name := cName

                hJson[cName] := aoVariables[RecNo()]:get_value()
                oRowBrowse:cargo({hJson, aoVariables})
            ELSE
                Inform(Config():get_config('ItIsNotVariable'))
            ENDIF
        CASE nKey == K_ALT_UP
            WMove(WRow() - 1, WCol())
        CASE nKey == K_ALT_DOWN
            WMove(WRow() + 1, WCol())
        CASE nKey == K_ALT_RIGHT
            WMove(WRow(), WCol() + 1)
        CASE nKey == K_ALT_LEFT
            WMove(WRow(), WCol() - 1)
        CASE nKey == K_ALT_ENTER
            WCenter(.T.)
    ENDCASE

RETURN ROWBROWSE_NOTHING
