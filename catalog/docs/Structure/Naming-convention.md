# Naming convention
For new feature we should follow this naming convention above.
Parts in `[ ]` are required. In `( )` are optional

> Important!
> Plural in naming should correspond feature name

## For features
### In app layer
All parts of names should be nouns.

**For UI components:**
`[Feature name](Purpose)[Component_name]
Example:
`TicketsFilterTextField`, `TicketsCard`

For pages in the end suffix `Page` is required

**For WMs**
`[Feauture name](Purpose)[Component name]WM`
Example:
`TicketsFilterTextFieldWM`, `TicketsCardWM`

**For Models**
`[Feauture name](Purpose)[Component name]Model`
Example:
`TicketsFilterTextFieldModel`, `TicketsCardModel`

### In feature layer
**For usecases**
`[Feature name][Action]Usecase`
Here `Action` is phrase described what this usecase do like `get list`, `delete item` and etc
Example:
`TicketsGetFilteredListUsecase`

**For repositories**
`[Feature name]Repository`
Example:
`TicketsRepository`

Remote and local I/O, plus DTO parsing, live in the repository implementation (or private helpers in the same feature). Do **not** add a separate `*Datasource` type as a layer.

## For general components
This components can be `View` layer implementation.
`[Component_name]View`
 For general component we just create only view part and interfaces for wms.
 [learn more]()

Or this components can be general widgets for whole app.
For example: `AppBarTitleWithAvatar`
