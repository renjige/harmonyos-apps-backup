import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { DailyFind, JournalStore } from '../../services/JournalStore'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionTime } from '../../models/PavilionModels'

@Component
export struct DailyFindPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State rows: DailyFind[] = []
  @State writing: boolean = false
  @State title: string = ''
  @State body: string = ''
  @State toastText: string = ''
  @State confirmId: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.rows = JournalStore.findList()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0 && this.body.trim().length === 0) {
      this.showToast('写下今天学到的小知识或小技巧')
      return
    }
    await JournalStore.saveFind(this.title, this.body)
    this.title = ''
    this.body = ''
    this.writing = false
    this.reload()
    this.showToast('今日发现已记下')
  }

  private async remove(id: string): Promise<void> {
    if (this.confirmId !== id) {
      this.confirmId = id
      this.showToast('再点一次确认删除')
      return
    }
    await JournalStore.deleteFind(id)
    this.confirmId = ''
    this.reload()
    this.showToast('已删除')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.writing ? '记下今日发现' : '每日发现记录',
        onClose: (): void => { PavilionDetailNav.close() }
      }) {
        if (this.writing) {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              Text(`今天 · ${PavilionTime.todayKey()}`)
                .fontSize(13)
                .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                .width('100%')
              TextInput({ text: this.title, placeholder: '今天学到的小知识 / 发现的小技巧' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding({ left: 14, right: 14 })
                .borderRadius(12)
                .onChange((v: string): void => { this.title = v })
              TextArea({ text: this.body, placeholder: '补充备注：在哪里看到的、准备怎么用' })
                .width('100%')
                .height(140)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding(14)
                .borderRadius(12)
                .onChange((v: string): void => { this.body = v })
              AppButton({ label: '保存今日发现', onTap: (): void => { void this.save() } })
              AppButton({
                label: '取消',
                variant: 'secondary',
                onTap: (): void => { this.writing = false }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        } else if (this.rows.length === 0) {
          AppEmpty({
            title: '还没有每日发现',
            description: '每天记一条新知识或小技巧，慢慢养成探索习惯。',
            actionLabel: '记下今天',
            onAction: (): void => { this.writing = true }
          })
        } else {
          Column() {
            AppButton({
              label: '再记一条今日发现',
              onTap: (): void => { this.writing = true }
            })
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.rows, (n: DailyFind) => {
                  Column({ space: 6 }) {
                    Text(n.dateKey)
                      .fontSize(12)
                      .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    Text(n.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                      .width('100%')
                    Text(n.body)
                      .fontSize(13)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                      .maxLines(5)
                      .width('100%')
                    Text(this.confirmId === n.id ? '再点一次删除' : '删除')
                      .fontSize(12)
                      .fontColor(Theme.colors().danger)
                      .onClick((): void => { void this.remove(n.id) })
                  }
                  .width('100%')
                  .padding(12)
                  .alignItems(HorizontalAlign.Start)
                  .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                  .borderRadius(12)
                }, (n: DailyFind) => n.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(20)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
