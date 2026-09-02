import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ExploreLog, JournalStore } from '../../services/JournalStore'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'

class LogCat {
  id: string = 'like'
  label: string = '最近喜欢的事物'
}

@Component
export struct ExploreLogPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State rows: ExploreLog[] = []
  @State writing: boolean = false
  @State title: string = ''
  @State body: string = ''
  @State cat: string = 'like'
  @State toastText: string = ''
  @State confirmId: string = ''
  private cats: LogCat[] = ExploreLogPane.buildCats()

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private static buildCats(): LogCat[] {
    const a = new LogCat()
    const b = new LogCat()
    b.id = 'find'
    b.label = '新发现的知识'
    const c = new LogCat()
    c.id = 'topic'
    c.label = '感兴趣的话题'
    const list: LogCat[] = []
    list.push(a)
    list.push(b)
    list.push(c)
    return list
  }

  private reload(): void {
    this.rows = JournalStore.logList()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0 && this.body.trim().length === 0) {
      this.showToast('请先写下标题或描述')
      return
    }
    await JournalStore.saveLog(this.title, this.body, this.cat)
    this.title = ''
    this.body = ''
    this.writing = false
    this.reload()
    this.showToast('探索记录已保存')
  }

  private async remove(id: string): Promise<void> {
    if (this.confirmId !== id) {
      this.confirmId = id
      this.showToast('再点一次确认删除')
      return
    }
    await JournalStore.deleteLog(id)
    this.confirmId = ''
    this.reload()
    this.showToast('已删除')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.writing ? '记一条探索' : '兴趣探索记录',
        onClose: (): void => { PavilionDetailNav.close() }
      }) {
        if (this.writing) {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              Text('分类')
                .fontSize(13)
                .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.cats, (c: LogCat) => {
                  Text(c.label)
                    .fontSize(13)
                    .fontColor(this.cat === c.id ? Theme.colors().brandOnPrimary : Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.cat === c.id ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.brandBox(this.themeEpoch, this.darkModeOn))
                    .borderRadius(8)
                    .onClick((): void => { this.cat = c.id })
                }, (c: LogCat) => c.id)
              }
              .width('100%')
              TextInput({ text: this.title, placeholder: '标题，如：最近喜欢的事物' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding({ left: 14, right: 14 })
                .borderRadius(12)
                .onChange((v: string): void => { this.title = v })
              TextArea({ text: this.body, placeholder: '描述：为什么感兴趣、想继续了解什么' })
                .width('100%')
                .height(140)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding(14)
                .borderRadius(12)
                .onChange((v: string): void => { this.body = v })
              AppButton({ label: '保存到兴趣档案', onTap: (): void => { void this.save() } })
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
            title: '还没有探索记录',
            description: '记下喜欢的事物、新发现或想深入的话题，形成个人兴趣档案。',
            actionLabel: '记一条',
            onAction: (): void => { this.writing = true }
          })
        } else {
          Column() {
            AppButton({
              label: '记一条新探索',
              onTap: (): void => { this.writing = true }
            })
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.rows, (n: ExploreLog) => {
                  Column({ space: 6 }) {
                    Text(n.categoryLabel())
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
                      .maxLines(4)
                      .width('100%')
                    Text(n.createdAt)
                      .fontSize(12)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
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
                }, (n: ExploreLog) => n.id)
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
