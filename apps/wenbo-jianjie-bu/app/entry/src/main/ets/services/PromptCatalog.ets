export class PromptCatalog {
  static todayQuestion(): string {
    const list = PromptCatalog.daily()
    const d = new Date()
    const idx = (d.getFullYear() + d.getMonth() * 31 + d.getDate()) % list.length
    if (idx < 0 || idx >= list.length) {
      return list[0]
    }
    return list[idx]
  }

  static weekQ1(): string {
    return '这周哪一个判断被现实碰到了？它应验、落空，还是要修正？'
  }

  static weekQ2(): string {
    return '这周你反复想到、却还没写成见解的一件事是什么？'
  }

  static weekQ3(): string {
    return '下周你想看清楚的一件事是什么？准备用什么信号来验证？'
  }

  private static daily(): string[] {
    const list: string[] = []
    list.push('你最近坚持的一个判断，依据到底是事实还是习惯？')
    list.push('如果把今天最忙的一件事删掉，真正会失去什么？')
    list.push('有谁的一句话你不同意，但还没写出自己的理由？')
    list.push('你正在避免做的决定，再拖三天会变成什么代价？')
    list.push('上周那个「所以呢」，今天还成立吗？')
    list.push('你把什么误当成了努力，其实只是重复？')
    list.push('如果只能保留一条近期见解给未来的自己，会留哪条？')
    list.push('当前最容易被情绪带跑的判断是哪一个？')
    list.push('有哪个问题，你一直在收集信息，却迟迟不下判断？')
    list.push('今天看见的现象，三天后还会让你在意吗？')
    list.push('你对谁的期待过高了？证据是什么？')
    list.push('哪件小事其实暴露了你真正在乎的标准？')
    list.push('如果站在反对者那边，你的判断哪里最脆弱？')
    list.push('你最近一次改变想法，是被什么事实推了一把？')
    list.push('把「我应该」改成「我选择」，句子还通顺吗？')
    list.push('有哪个目标其实是别人的，却写在了你的待办里？')
    list.push('你用什么信号判断自己在进步，而不只是在忙碌？')
    list.push('今天的闪念里，哪一句值得变成可验证的判断？')
    list.push('你最不想回看的一条旧笔记，卡在什么情绪上？')
    list.push('如果这周只验证一个假设，你会选哪一个？')
    list.push('哪件重复发生的事，你还当偶然在处理？')
    list.push('你对「以后再说」的事情，真正的截止日期是哪天？')
    list.push('把复杂问题写成三句话：现象、判断、所以呢。')
    list.push('谁会因为你这个判断受益，谁会受损？')
    list.push('你最近一次说「没办法」，有没有第二种办法？')
    list.push('今天读到或听到的一句话，你的理解是什么？')
    list.push('若明天只能做一件与思考有关的事，你会写下什么？')
    list.push('你把什么当成个性，其实只是没被挑战过的习惯？')
    return list
  }
}
