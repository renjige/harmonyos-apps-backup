import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { SaituDetailNav } from '../../services/SaituDetailNav'

class SportComposeOption {
  key: string = ''
  label: string = ''
  hint: string = ''

  static all(): SportComposeOption[] {
    const rows: SportComposeOption[] = []
    const defs: string[][] = [
      ['record', '赛事记录', '现场观赛 · 比分 · 配图'],
      ['note', '比赛笔记', '战术观察与个人心得'],
      ['review', '赛事复盘', '四段结构化复盘模板'],
      ['plan', '观赛计划', '待看赛事与关注状态'],
      ['album', '赛事纪念册', '世界杯/季后赛等专题册'],
      ['training', '训练日志', '自主训练时长与强度'],
      ['follow', '球队与选手关注', '关联后续赛事档案']
    ]
    for (const d of defs) {
      const o = new SportComposeOption()
      o.key = d[0]
      o.label = d[1]
      o.hint = d[2]
      rows.push(o)
    }
    return rows
  }
}

/** 添加赛事档案 — 全屏选择页，顶部返回可关闭 */
@Component
export struct SportComposerSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private options: SportComposeOption[] = SportComposeOption.all()

  private close(): void {
    SaituDetailNav.closeSportComposer()
  }

  @Builder
  OptionRow(item: SportComposeOption) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(item.label)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(item.hint)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => {
      SaituDetailNav.pickSportComposer(item.key)
    })
  }

  build() {
    Column() {
      AppNavBar({
        title: '添加赛事档案',
        onBack: (): void => { this.close() }
      })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('选择要创建的类型，将直接进入编辑页')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          ForEach(this.options, (item: SportComposeOption) => {
            this.OptionRow(item)
          }, (item: SportComposeOption) => item.key)

          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.close() }
          })

          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
