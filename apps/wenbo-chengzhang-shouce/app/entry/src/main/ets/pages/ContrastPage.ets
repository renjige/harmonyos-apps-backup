import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { CreateBoardRequest, GrowthRecordItem } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { GrowthDetailNav } from '../services/GrowthDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct ContrastPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onWriteRecord: () => void = () => {}
  onSaved: () => void = () => {}
  @State records: GrowthRecordItem[] = []
  @State beforeId: string = ''
  @State afterId: string = ''
  @State loading: boolean = true
  @State submitting: boolean = false
  @State toastText: string = ''
  @State errorText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private usable(records: GrowthRecordItem[]): GrowthRecordItem[] {
    const out: GrowthRecordItem[] = []
    for (const r of records) {
      if (r.title.indexOf('月度主题') >= 0 || r.title.indexOf('月报 ·') >= 0) {
        continue
      }
      out.push(r)
    }
    return out
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      const all = this.usable(await GrowthBizService.loadRecords(this.currentUsername))
      this.records = all
      if (all.length >= 2) {
        this.afterId = all[0].id
        this.beforeId = all[all.length - 1].id
      }
    } else {
      this.records = []
    }
    this.loading = false
  }

  private findById(id: string): GrowthRecordItem | undefined {
    for (const r of this.records) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  private swap(): void {
    const a = this.beforeId
    this.beforeId = this.afterId
    this.afterId = a
  }

  private contrastBody(): string {
    const before = this.findById(this.beforeId)
    const after = this.findById(this.afterId)
    if (before === undefined || after === undefined) {
      return ''
    }
    return `对照起点：${before.recordDate} · ${before.title}\n${before.summary}\n\n对照近点：${after.recordDate} · ${after.title}\n${after.summary}\n\n看见的变化：从「${before.title}」走到「${after.title}」。把这条对照卡留在时间轴，提醒自己不是原地踏步。`
  }

  private async saveCard(): Promise<void> {
    if (!AuthService.requireAuth('create_record')) {
      this.onRequireAuth()
      return
    }
    const body = this.contrastBody()
    if (body.length === 0) {
      this.errorText = '请先选出两条记录'
      return
    }
    if (this.beforeId === this.afterId) {
      this.errorText = '请选择两条不同的记录'
      return
    }
    this.submitting = true
    const after = this.findById(this.afterId)
    const req = new CreateBoardRequest()
    req.title = `对照卡 · ${after !== undefined ? after.recordDate : ''}`
    req.description = body
    req.body = body
    req.coverKey = 'board_editorial'
    req.userId = this.currentUsername
    const created = await GrowthBizService.createMoodBoard(req)
    this.submitting = false
    if (created !== undefined) {
      this.onSaved()
      this.toastText = '对照卡已写入时间轴'
      const id = created.id
      setTimeout(() => {
        this.toastText = ''
        this.onClose()
        if (id.length > 0) {
          GrowthDetailNav.openBoard(id)
        }
      }, 700)
    } else {
      this.errorText = '保存失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '前后对照卡', subtitle: '用两条记录看见自己的变化' })
        if (this.loading) {
          AppLoading({ label: '加载记录…' }).layoutWeight(1)
        } else if (this.records.length < 2) {
          Column() {
            AppEmpty({
              title: '至少需要两条成长记录',
              description: '先写两条记录，才能生成前后对照卡',
              actionLabel: '去写记录',
              onAction: (): void => {
                this.onClose()
                this.onWriteRecord()
              }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.hero_typography'))
                .width('100%')
                .height(132)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Text('点选一条作为「过去」，再点另一条作为「现在」。默认已选最早与最近。')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              ForEach(this.records, (item: GrowthRecordItem) => {
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(item.recordDate)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  Text(item.id === this.beforeId ? '当前：对照起点（过去）' :
                    (item.id === this.afterId ? '当前：对照近点（现在）' : '点击设为对照近点'))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({
                  width: (item.id === this.beforeId || item.id === this.afterId) ? 2 : 1,
                  color: (item.id === this.beforeId || item.id === this.afterId) ?
                    Theme.colors().brandPrimary : Theme.colors().strokeHairline
                })
                .onClick((): void => {
                  if (item.id === this.afterId) {
                    this.beforeId = item.id
                  } else {
                    this.afterId = item.id
                  }
                })
              }, (item: GrowthRecordItem) => item.id)
              AppButton({
                label: '交换过去 / 现在',
                variant: 'secondary',
                onTap: (): void => { this.swap() }
              })
              Text(this.contrastBody())
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.xl)
              if (this.errorText.length > 0) {
                Text(this.errorText)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().danger)
                  .width('100%')
              }
              AppButton({
                label: this.submitting ? '保存中…' : '生成对照卡并写入时间轴',
                onTap: (): void => { void this.saveCard() }
              })
              AppButton({
                label: '返回',
                variant: 'secondary',
                onTap: (): void => { this.onClose() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
