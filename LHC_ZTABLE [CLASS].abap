CLASS lhc_ZTABLE DEFINITION INHERITING FROM cl_abap_behavior_handler. 
  PRIVATE SECTION. 

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ztable RESULT result.

    METHODS setActive FOR MODIFY
      IMPORTING keys FOR ACTION ztable~setActive RESULT result.

    METHODS changeSalary FOR DETERMINE ON SAVE
      IMPORTING keys FOR ztable~changeSalary.

    METHODS validateAge FOR VALIDATE ON SAVE
      IMPORTING keys FOR ztable~validateAge.

ENDCLASS.

CLASS lhc_ZTABLE IMPLEMENTATION. 

  METHOD get_instance_features.

    READ ENTITIES OF ZI_ZTABLE005 IN LOCAL MODE
        ENTITY ZTABLE
            FIELDS ( Active ) WITH CORRESPONDING #( keys )
        RESULT DATA(members)
        FAILED failed.

    result =
        VALUE #(
            FOR member IN members
                LET status = COND #( WHEN member-Active = abap_true
                                        THEN if_abap_behv=>fc-o-disabled
                                        ELSE if_abap_behv=>fc-o-enabled )

                                        IN

                                        ( %tky = member-%tky
                                          %action-setActive = status
                                         ) ).

  ENDMETHOD.

  METHOD setActive.

    MODIFY ENTITIES OF ZI_ZTABLE005 IN LOCAL MODE
        ENTITY ZTABLE
            UPDATE
                FIELDS ( Active )
                WITH VALUE #( FOR key IN keys
                            ( %tky = key-%tky
                              Active = abap_true ) )
        FAILED failed
        REPORTED reported.

    READ ENTITIES OF ZI_ZTABLE005 IN LOCAL MODE
        ENTITY ZTABLE
            ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(members).

    result = VALUE #( FOR member in members
                    ( %tky = member-%tky
                      %param = member ) ).

  ENDMETHOD.

  METHOD changeSalary.

    READ ENTITIES OF ZI_ZTABLE005 IN LOCAL MODE
        ENTITY ZTABLE
            FIELDS ( Role ) WITH CORRESPONDING #( keys )
        RESULT DATA(members).

    LOOP AT members INTO DATA(member).

        IF member-role = 'Developer'.
            MODIFY ENTITIES OF ZI_ZTABLE005 IN LOCAL MODE
                ENTITY ZTABLE
                    UPDATE
                        FIELDS ( Salary )
                        WITH VALUE #( ( %tky = member-%tky
                                        Salary = 7000 ) ).
        ENDIF.

        IF member-role = 'Leader'.
            MODIFY ENTITIES OF ZI_ZTABLE005 IN LOCAL MODE
                ENTITY ZTABLE
                    UPDATE
                        FIELDS ( Salary )
                        WITH VALUE #( ( %tky = member-%tky
                                        Salary = 10000 ) ).
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateAge.

    READ ENTITIES OF ZI_ZTABLE005 IN LOCAL MODE
        ENTITY ZTABLE
            FIELDS ( Age ) WITH CORRESPONDING #( keys )
        RESULT DATA(members).

    LOOP AT members INTO DATA(member).

        IF member-age < 21.
            APPEND VALUE #( %tky = member-%tky ) TO failed-ztable.
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
