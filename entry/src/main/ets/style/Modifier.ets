@Styles function itemDividerStyle() {
  .margin({
    left: $r('sys.float.ohos_id_card_margin_start'),
    right: $r('sys.float.ohos_id_card_margin_end'),
  })
}

@Builder export function itemDividerBuilder() {
  Divider().itemDividerStyle()
}

class GroupAttributeModifier implements AttributeModifier<CommonAttribute> {

  applyNormalAttribute(instance: CommonAttribute): void {
    instance.width('90%')
    instance.backgroundColor($r('sys.color.comp_background_list_card'))
    instance.borderRadius($r('sys.float.ohos_id_corner_radius_card'))
    instance.clip(true)
    instance.margin({
      top: $r('sys.float.ohos_id_elements_margin_vertical_l')
    })
  }

}

export const groupAttributeModifier = new GroupAttributeModifier()

class WindowAttributeModifier implements AttributeModifier<CommonAttribute> {

  applyNormalAttribute(instance: CommonAttribute): void {
    instance.width('100%')
    instance.height('100%')
    instance.backgroundColor($r('sys.color.background_secondary'))
  }

}

export const windowAttributeModifier = new WindowAttributeModifier()

class ClickableModifier implements AttributeModifier<CommonAttribute> {

  applyNormalAttribute(instance: CommonAttribute): void {
    instance.opacity(1.0)
    instance.backgroundColor(Color.Transparent)
  }

  applyPressedAttribute(instance: CommonAttribute): void {
    instance.opacity(0.7)
    instance.backgroundColor($r('sys.color.interactive_pressed'))
  }

}

export const clickableModifier = new ClickableModifier()