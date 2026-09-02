import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { SafetyService, SafetyItem } from '../services/SafetyService'

@Component
export struct SafetyDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @State item: SafetyItem = new SafetyItem()
  @State loading: boolean = true
  @State saving: boolean = false
  @State noteInput: string = ''
  @State tip: string = ''
  onBack: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.loadDetail()
  }

  private async loadDetail(): Promise<void> {
    this.loading = true
    const all = await SafetyService.list()
    const found = all.filter((s) => s.id === this.itemId)
    if (found.length > 0) {
      this.item = found[0]
    }
    this.loading = false
  }

  private async doTransition(nextStatus: string): Promise<void> {
    if (this.saving) {
      return
    }
    this.saving = true
    this.tip = ''
    const ok = await SafetyService.transitionStatus(this.item.id, nextStatus, this.noteInput)
    this.saving = false
    if (ok) {
      this.item.status = nextStatus
      if (nextStatus === 'closed') {
        this.item.closedAt = '已关闭'
        this.item.rectificationNote = this.noteInput
      }
      this.tip = `状态已更新为：${SafetyService.statusLabel(nextStatus)}`
      this.noteInput = ''
      this.onChanged()
    } else {
      this.tip = '操作失败，请稍后重试'
    }
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().textTertiary)
        .width(80)
      Text(value.length > 0 ? value : '—')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
  }

  build() {
    Column() {
      AppNavBar({ title: '巡检详情', onBack: () => this.onBack() })
      if (this.loading) {
        Column() {
          Text('加载中…')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textTertiary)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            AppCard({ title: this.item.title }) {
              Column({ space: Theme.space.s1 }) {
                Row({ space: Theme.space.s2 }) {
                  Text(SafetyService.levelLabel(this.item.level))
                    .fontSize(Theme.type.overline)
                    .fontColor(SafetyService.levelColor(this.item.level))
                    .padding({ left: Theme.space.s2, right: Theme.space.s2, top: 2, bottom: 2 })
                    .backgroundColor(Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.xs)
                  Text(SafetyService.statusLabel(this.item.status))
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }

            AppCard({ title: '巡检信息' }) {
              Column() {
                this.InfoRow('位置', this.item.location)
                Divider().color(Theme.colors().strokeHairline).strokeWidth(1)
                this.InfoRow('类型', SafetyService.typeLabel(this.item.type))
                Divider().color(Theme.colors().strokeHairline).strokeWidth(1)
                this.InfoRow('检查人', this.item.inspectorName)
                Divider().color(Theme.colors().strokeHairline).strokeWidth(1)
                this.InfoRow('发现时间', this.item.createdAt)
                Divider().color(Theme.colors().strokeHairline).strokeWidth(1)
                this.InfoRow('截止日期', this.item.dueAt)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }

            if (this.item.findings.length > 0) {
              AppCard({ title: '发现情况' }) {
                Text(this.item.findings)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
            }

            if (this.item.status === 'open' || this.item.status === 'rectifying') {
              AppCard({ title: '处置备注' }) {
                TextInput({ text: this.noteInput, placeholder: this.item.status === 'open' ? '填写整改方案（可选）' : '填写验收说明' })
                  .height(44)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.sm)
                  .onChange((v: string) => { this.noteInput = v })
              }
            }

            if (this.tip.length > 0) {
              Text(this.tip)
                .fontSize(Theme.type.subhead)
                .fontColor(this.tip.includes('失败') ? Theme.colors().danger : Theme.colors().success)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }

            if (this.item.status === 'open') {
              AppButton({
                label: this.saving ? '处理中…' : '开始整改',
                onTap: () => { this.doTransition('rectifying') }
              })
            } else if (this.item.status === 'rectifying') {
              AppButton({
                label: this.saving ? '提交中…' : '提交验收关闭',
                onTap: () => { this.doTransition('closed') }
              })
            }

            if (this.item.status === 'closed' && this.item.closedAt.length > 0) {
              Text(`已关闭：${this.item.closedAt}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s8
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
