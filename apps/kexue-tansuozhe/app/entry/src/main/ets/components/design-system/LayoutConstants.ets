/** 底部 Tab 占位：悬浮 Dock 高 56 + 底距 12 + 缓冲 12 */
export class LayoutConstants {
  static readonly TAB_BAR_HEIGHT: number = 56
  static readonly TAB_DOCK_BOTTOM: number = 12
  static readonly TAB_SAFE_BOTTOM: number = 12

  static tabBarInset(): number {
    return LayoutConstants.TAB_BAR_HEIGHT + LayoutConstants.TAB_DOCK_BOTTOM + LayoutConstants.TAB_SAFE_BOTTOM
  }
}
